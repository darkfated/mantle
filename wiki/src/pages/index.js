import Link from "@docusaurus/Link";
import useDocusaurusContext from "@docusaurus/useDocusaurusContext";
import Layout from "@theme/Layout";
import styles from "./index.module.css";

export default function Home() {
  const { siteConfig } = useDocusaurusContext();

  return (
    <Layout title={siteConfig.title} description={siteConfig.tagline}>
      <main className={styles.main}>
        <h1 className={styles.title}>Mantle</h1>
        <p className={styles.subtitle}>
          Библиотека пользовательского интерфейса и рендера для Garry's Mod
        </p>
        <Link className={styles.button} to="/docs/intro">
          Посмотреть
        </Link>
      </main>
    </Layout>
  );
}
