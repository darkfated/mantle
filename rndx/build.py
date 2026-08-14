import base64
import io
import re
import shutil
import struct
import subprocess
import sys
import time
from pathlib import Path
from typing import TypedDict


class GMAEntry(TypedDict):
    name: str
    content: bytes


_GMA_HEADER = b"GMAD"
_GMA_VERSION = 3

_SHADER_VERSIONS = ("20b", "30")
_FALLBACK_VERSION = "20b"


def _write(buf: io.BytesIO, data: bytes) -> None:
    _ = buf.write(data)


def _write_c_string(buf: io.BytesIO, s: str) -> None:
    if "\0" in s:
        raise ValueError("String contains null byte")
    _write(buf, s.encode("utf-8") + b"\0")


def build_gma(name: str, steam_id64: int, entries: list[GMAEntry]) -> bytes:
    buf = io.BytesIO()
    _write(buf, _GMA_HEADER)
    _write(buf, struct.pack("B", _GMA_VERSION))
    _write(buf, struct.pack("<Q", steam_id64))
    _write(buf, struct.pack("<Q", int(time.time())))
    _write(buf, b"\0")
    _write_c_string(buf, name)
    _write_c_string(buf, "")
    _write_c_string(buf, "unknown")
    _write(buf, struct.pack("<i", 1))
    for i, entry in enumerate(entries, 1):
        _write(buf, struct.pack("<I", i))
        _write_c_string(buf, entry["name"])
        _write(buf, struct.pack("<Q", len(entry["content"])))
        _write(buf, struct.pack("<I", 0))
    _write(buf, struct.pack("<I", 0))
    for entry in entries:
        _write(buf, entry["content"])
    _write(buf, struct.pack("<I", 0))
    return buf.getvalue()


def _parse_shader_list(list_path: Path) -> list[tuple[str, list[str]]]:
    content = list_path.read_text(encoding="utf-8-sig")
    entries: list[tuple[str, list[str]]] = []
    for raw_line in content.splitlines():
        line = raw_line.strip()
        if not line or line.startswith("//"):
            continue

        versions = re.findall(r"-v-([0-9a-zA-Z]+)", line)
        if not versions:
            versions = [_FALLBACK_VERSION]

        cleaned = re.sub(r"\s*-v-[0-9a-zA-Z]+", "", line).strip()
        entries.append((cleaned, versions))
    return entries


def _compile_shaders(root: Path) -> None:
    list_path = root / "compile_shader_list.txt"
    if not list_path.exists():
        print(f"Error: {list_path} does not exist.")
        sys.exit(1)

    shader_exe = root / "ShaderCompile.exe"
    if not shader_exe.exists():
        print(f"Error: {shader_exe} does not exist.")
        sys.exit(1)

    shaderpath = str(root / "src")
    for hlsl, versions in _parse_shader_list(list_path):
        for version in versions:
            args = ["/O", "3", "-ver", version, "-shaderpath", shaderpath, hlsl]
            print(f"Compiling '{hlsl}' with version '{version}'")
            result = subprocess.run([str(shader_exe), *args], cwd=root)
            if result.returncode != 0:
                print(f"Error: ShaderCompile.exe failed for {hlsl} version {version}")
                sys.exit(result.returncode)


def _load_shader_entries(root: Path, version: str) -> list[GMAEntry]:
    shaders_dir = root / "src/shaders/fxc"
    if not shaders_dir.exists():
        print(f"Error: {shaders_dir} does not exist.")
        sys.exit(1)

    entries: list[GMAEntry] = []
    for f in sorted(shaders_dir.iterdir()):
        if f.is_file():
            entries.append({
                "name": f"shaders/fxc/{version}_{f.name}",
                "content": f.read_bytes(),
            })
    return entries


def _build_lua(root: Path, version: str, b64_data: str) -> str:
    rndx_path = root / "src/rndx.lua"
    if not rndx_path.exists():
        print(f"Error: {rndx_path} does not exist.")
        sys.exit(1)

    lua_content = rndx_path.read_text(encoding="utf-8")
    lua_content = lua_content.replace("SHADERS_VERSION_PLACEHOLDER", version)
    return lua_content.replace("SHADERS_GMA_PLACEHOLDER", b64_data)


def _write_outputs(root: Path, lua_content: str) -> None:
    output_path = root / "src/rndx_compiled.lua"
    output_path.write_text(lua_content, encoding="utf-8")
    print(f"Generated {output_path}")

    target_path = root.parent / "lua/mantle/modules/rndx.lua"
    target_path.parent.mkdir(parents=True, exist_ok=True)
    _ = shutil.copy2(output_path, target_path)
    print(f"Copied to {target_path.resolve()}")


def main() -> None:
    root = Path(__file__).resolve().parent
    _compile_shaders(root)

    version = str(int(time.time()))
    entries = _load_shader_entries(root, version)
    gma = build_gma(f"RNDX_{version}", 12345678901234567, entries)
    b64_data = base64.b64encode(gma).decode("utf-8")

    _write_outputs(root, _build_lua(root, version, b64_data))


if __name__ == "__main__":
    main()
