import React from 'react';
import DoseResponseMain from './DoseResponseMain';
import BmdByLabMain from './BmdByLabMain';
import IntegrativeAnalysesMain from './IntegrativeAnalysesMain';
import DatasetsMain from './DatasetsMain';
import QualityControlMain from './QualityControlMain';
import AboutMain from './AboutMain';
import ResourcesMain from './ResourcesMain';

// Tab key constants — match the URL hash values
const TAB_ABOUT = 'about';
const TAB_CR = 'seazit_cr';
const TAB_BMC = 'seazit_bmcByLab';
const TAB_INT = 'seazit_integrative';
const TAB_DATASET = 'dataset';
const TAB_QC = 'quality-control';
const TAB_RESOURCES = 'resources';

// Legacy hash aliases — preserve backward-compat with old bookmarks (#cr, #bmc, #int, #qc)
const LEGACY_HASH_ALIASES = {
    'cr': TAB_CR,
    'bmc': TAB_BMC,
    'int': TAB_INT,
    'qc': TAB_QC,
};

const VALID_TABS = [TAB_ABOUT, TAB_CR, TAB_BMC, TAB_INT, TAB_DATASET, TAB_QC, TAB_RESOURCES];

// Nav element IDs set in base.html
const NAV_IDS = {
    [TAB_ABOUT]: 'nav-tab-about',
    [TAB_CR]: 'nav-tab-cr',
    [TAB_BMC]: 'nav-tab-bmc',
    [TAB_INT]: 'nav-tab-int',
    [TAB_DATASET]: 'nav-tab-dataset',
    [TAB_QC]: 'nav-tab-qc',
    [TAB_RESOURCES]: 'nav-tab-resources',
};

// Shiny iframe URLs
const SHINY_URLS = {
    [TAB_DATASET]: 'https://rstudio.niehs.nih.gov/seazit_dataset/',
    [TAB_QC]: 'https://rstudio.niehs.nih.gov/seazit_qc/',
};

function getTabFromHash() {
    const hash = window.location.hash.replace('#', '');
    if (LEGACY_HASH_ALIASES[hash]) return LEGACY_HASH_ALIASES[hash];
    return VALID_TABS.includes(hash) ? hash : TAB_ABOUT;
}

class Seazitdiver extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            activeTab: getTabFromHash(),
        };
        this.switchTab = this.switchTab.bind(this);
        this.handleHashChange = this.handleHashChange.bind(this);
    }

    componentDidMount() {
        // Wire nav tab link clicks to in-page switching
        VALID_TABS.forEach((tabKey) => {
            const el = document.getElementById(NAV_IDS[tabKey]);
            if (el) {
                el.addEventListener('click', (e) => {
                    e.preventDefault();
                    this.switchTab(tabKey);
                });
            }
        });

        // Handle browser back/forward button
        window.addEventListener('hashchange', this.handleHashChange);

        // Set initial active class on nav
        this.updateNavActiveClass(this.state.activeTab);

        // Wire up resizeIframe for both Shiny iframes.
        // resizeIframe attaches an onload handler — iframes load once and
        // stay alive in the DOM (display:none when inactive), preserving
        // Shiny session state across tab switches.
        if (window.apps && window.apps.resizeIframe) {
            const dsIframe = document.getElementById('iframe-dataset');
            const qcIframe = document.getElementById('iframe-qc');
            if (dsIframe) window.apps.resizeIframe(dsIframe);
            if (qcIframe) window.apps.resizeIframe(qcIframe);
        }
    }

    componentWillUnmount() {
        window.removeEventListener('hashchange', this.handleHashChange);
    }

    handleHashChange() {
        const tabKey = getTabFromHash();
        this.setState({ activeTab: tabKey });
        this.updateNavActiveClass(tabKey);
    }

    switchTab(tabKey) {
        // Update URL hash (triggers hashchange, which updates state)
        window.location.hash = tabKey;
    }

    updateNavActiveClass(activeTab) {
        VALID_TABS.forEach((tabKey) => {
            const el = document.getElementById(NAV_IDS[tabKey]);
            if (el) {
                if (tabKey === activeTab) {
                    el.classList.add('active');
                } else {
                    el.classList.remove('active');
                }
            }
        });
    }

    componentDidUpdate(prevProps, prevState) {
        if (prevState.activeTab !== this.state.activeTab) {
            // Fire a resize event so Plotly/D3 plots re-measure their container
            // after being switched from display:none to display:block.
            // 150ms gives the browser enough time to fully apply the CSS layout
            // change before components measure their container width.
            setTimeout(() => {
                window.dispatchEvent(new Event('resize'));
            }, 150);
        }
    }

    render() {
        const { activeTab } = this.state;
        return (
            <div>
                {/* Static content tabs — no state, no API, instant render */}
                <div style={{ display: activeTab === TAB_ABOUT ? 'block' : 'none' }}>
                    <AboutMain />
                </div>
                <div style={{ display: activeTab === TAB_RESOURCES ? 'block' : 'none' }}>
                    <ResourcesMain />
                </div>

                {/* React tabs — components stay mounted, state fully preserved */}
                <div style={{ display: activeTab === TAB_CR ? 'block' : 'none' }}>
                    <DoseResponseMain />
                </div>
                <div style={{ display: activeTab === TAB_BMC ? 'block' : 'none' }}>
                    <BmdByLabMain />
                </div>
                <div style={{ display: activeTab === TAB_INT ? 'block' : 'none' }}>
                    <IntegrativeAnalysesMain />
                </div>

                {/* Shiny iframe tabs — iframes stay in DOM, Shiny session preserved */}
                <div style={{ display: activeTab === TAB_DATASET ? 'block' : 'none' }}>
                    <DatasetsMain />
                    <iframe
                        id="iframe-dataset"
                        frameBorder={0}
                        src={SHINY_URLS[TAB_DATASET]}
                        style={{ width: '100%' }}
                    />
                </div>
                <div style={{ display: activeTab === TAB_QC ? 'block' : 'none' }}>
                    <QualityControlMain />
                    <iframe
                        id="iframe-qc"
                        frameBorder={0}
                        src={SHINY_URLS[TAB_QC]}
                        style={{ width: '100%' }}
                    />
                </div>
            </div>
        );
    }
}

export default Seazitdiver;
