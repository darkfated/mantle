import Link from "@docusaurus/Link";
import useDocusaurusContext from "@docusaurus/useDocusaurusContext";
import { translate } from "@docusaurus/Translate";
import Layout from "@theme/Layout";
import styles from "./index.module.css";

export default function Home() {
  const { siteConfig, i18n } = useDocusaurusContext();
  const { baseUrl } = siteConfig;
  // In non-default locale builds Docusaurus already appends the locale to baseUrl.
  const localeSuffix = `${i18n.currentLocale}/`;
  const siteBaseUrl = baseUrl.endsWith(localeSuffix)
    ? baseUrl.slice(0, -localeSuffix.length)
    : baseUrl;

  return (
    <Layout title={siteConfig.title} description={siteConfig.tagline}>
      <main className={styles.main}>
        <h1 className={styles.title}>Mantle</h1>
        <p className={styles.subtitle}>
          {translate({
            id: "home.subtitle",
            message: "A UI and renderer library for Garry's Mod",
          })}
        </p>
        <Link className={styles.button} to={`${baseUrl}docs/intro`}>
          {translate({ id: "home.view", message: "View documentation" })}
        </Link>

        <div className={styles.langSwitch}>
          <a
            className={`${styles.langOption} ${i18n.currentLocale === "en" ? styles.langOptionActive : ""}`}
            href={siteBaseUrl}
          >
            English
          </a>
          <span className={styles.langDivider}>/</span>
          <a
            className={`${styles.langOption} ${i18n.currentLocale === "ru" ? styles.langOptionActive : ""}`}
            href={`${siteBaseUrl}ru/`}
          >
            Русский
          </a>
        </div>
      </main>
    </Layout>
  );
}
