import DatasetsMain from './containers/DatasetsMain';
import QualityControlMain from './containers/QualityControlMain';
import DoseResponseMain from './containers/DoseResponseMain';
import BmdByLabMain from './containers/BmdByLabMain';
import IntegrativeAnalysesMain from './containers/IntegrativeAnalysesMain';
import Seazitdiver from './containers/Seazitdiver';

import { insertIntoDom } from './shared';

const renderDatasets = (el) => insertIntoDom(DatasetsMain, el),
    renderQualityControl = (el) => insertIntoDom(QualityControlMain, el),
    renderBmdByLab = (el) => insertIntoDom(BmdByLabMain, el),
    renderDoseResponse = (el) => insertIntoDom(DoseResponseMain, el),
    renderIntegrativeAnalyses = (el) => insertIntoDom(IntegrativeAnalysesMain, el),
    renderSeazitApp = (el) => insertIntoDom(Seazitdiver, el);

export {
    renderDatasets,
    renderQualityControl,
    renderDoseResponse,
    renderBmdByLab,
    renderIntegrativeAnalyses,
    renderSeazitApp,
};
