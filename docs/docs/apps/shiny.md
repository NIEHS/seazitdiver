# Shiny applications

## Purpose

Two SEAZIT-DIVER tabs are implemented in R Shiny and embedded in the Django application as iframes:

- **Dataset tab** - experimental design, test substances, lab-specific protocols, and phenotype ontology mapping. Source placeholder: `shiny/seazit_datasets/`. Currently served from [https://rstudio.niehs.nih.gov/seazit_dataset/](https://rstudio.niehs.nih.gov/seazit_dataset/).
- **Quality control tab** - plate-level and assay-level quality-control details on normalized response and variance in assay control response. Source placeholder: `shiny/seazit_qc/`. Currently served from [https://rstudio.niehs.nih.gov/seazit_qc/](https://rstudio.niehs.nih.gov/seazit_qc/).

Both apps were written by Jui-Hua Hsieh. The iframe URLs are configured in `project/seazit/assets/seazit/containers/Seazitdiver.js` (`SHINY_URLS`).

## Developer instructions

Shiny applications are created without header/footer or custom styles; the header, footer, and main page are hosted by the Django application and the Shiny app is embedded as an iframe. This keeps the Shiny apps portable and limits the number of applications to update when site styles change.

A jQuery script in Django resizes the iframe to its content; it is fragile and may need updating if the Shiny layout changes.

### Allowing cross-origin iframe access (dev only)

During development, you may wish to modify an iframe served from another origin. Start Google Chrome with [web security disabled](http://stackoverflow.com/questions/3102819/):

```bash
open -a "Google Chrome" --args --disable-web-security --user-data-dir
```
