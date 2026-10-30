import React from 'react';
import { useCallback, useRef } from 'react';
import ReactDOM from 'react-dom';
import PropTypes from 'prop-types';
import _ from 'lodash';
import * as d3 from 'd3';
import Loading from 'utils/Loading';
import BmdTable from './BmdTable';
import RankedBarchart, { submit_download_form } from './RankedBarchart';
import HelpButtonWidget from '../widgets/HelpButtonWidget';

import {
    getBmdsUrl,
    BMDVIZ_ACTIVITY,
    BMDVIZ_SELECTIVITY,
    BMD_CW, // svg_download_form,
    data_exportToJsonFile,
    CHEMLIST_80,
    CHEMFILTER_CHEMICIAL,
    NO_COLLAPSE,
    COLLAPSE_BY_READOUT,
    COLLAPSE_BY_CHEMICAL,
    printFloat,
    integrative_Granular,
    pod_med_processed,
    svg_download_form,
    INTVIZ_HEATMAP,
    renderNoDataAlert,
    exportCsv,
} from '../shared';

class RankedBarchartHandler extends React.Component {
    constructor(props) {
        super(props);
        // this.parseJSONToCSVStr = this.parseJSONToCSVStr.bind(this);
        this.state = { data: null };
    }

    fetchBmdData(url) {
        d3.json(url, (error, data) => {
            if (error) {
                let err = error.target.responseText.replace('["', '').replace('"]', '');
                this.setState({
                    data: [],
                    error: err,
                });
                return;
            }
            this.setState({ data });
        });
    }

    setDatasetKey(data) {
        data.key = `${data.endpoint_name}|${data.protocol_id}`;
        data.chemicalKey = `${data.casrn}|${data.dtxsid}`;
    }

    _getFilteredData() {
        let selectivityCheckedArray, data, plotData;

        if (this.props.visualization === BMDVIZ_ACTIVITY) {
            data = _.chain(this.state.data.bmd_activity_selectivity)
                .map((d) => {
                    return {
                        ...d,
                        y: d.casrn,
                    };
                })
                .sortBy('med_pod_med')
                .value();
        } else {
            selectivityCheckedArray = _.chain(this.props.selectivityList)
                .filter((r) => r.isChecked === true)
                .map('name')
                .uniq()
                .value();
            data = _.chain(this.state.data.bmd_activity_selectivity)
                .filter((i) => selectivityCheckedArray.includes(i.final_dev_call))
                .map((d) => {
                    return {
                        ...d,
                        y: d.casrn,
                        // ontologyGroupName: d[ontologyGroupType],
                        // title:
                        //     d[ontologyGroupType] + '+' + d.protocol_name_plot + '+' + d.preferred_name,
                    };
                })
                .sortBy('mean_selectivity')
                .reverse()
                .value();
        }
        // Per substance (groupBy casrn), pick the row with the lowest
        // non-mortality BMC and the row with the lowest mortality BMC.
        // Use _.minBy, not _.min: in lodash 4, _.min ignores the iteratee and
        // just returns the first row. pod_med_processed(null) is undefined, so
        // inactive rows are skipped. If a substance is inactive on every row,
        // _.minBy returns undefined; fall back to k[0] (its BMC is null, so
        // the table shows "-" and the chart skips it).
        plotData = _.chain(data)
            .groupBy('casrn')
            .map((k) => {
                let endpoint_names = _.chain(k)
                        .map('endpoint_name')
                        .uniq()
                        .value(),
                    minimimumNonViability =
                        _.minBy(k, (d) => pod_med_processed(d.med_pod_med)) || k[0],
                    minimimumViability =
                        _.minBy(k, (d) => pod_med_processed(d.mort_med_pod_med)) || k[0];
                let devtoxEndpoints = _.chain(k)
                    .filter((i) => i.final_dev_call === 'dev tox')
                    .map('endpoint_name')
                    .uniq()
                    .value();

                return {
                    casrn: k[0].casrn,
                    data: k,
                    endpoint_name: endpoint_names,
                    minimimumNonViability: {
                        ...minimimumNonViability,
                        endpoint_names_list: endpoint_names,
                    },
                    minimimumViability: {
                        ...minimimumViability,
                        endpoint_names_list: endpoint_names,
                    },
                    related_endpoint_names: endpoint_names,
                    related_devtoxEndpoints: devtoxEndpoints,
                    protocol_id: minimimumNonViability.protocol_id,
                    preferred_name: minimimumNonViability.preferred_name,
                    use_category1: minimimumNonViability.use_category1,
                    malformation: minimimumNonViability.malformation,
                    combin_ontology: minimimumNonViability.combin_ontology,
                    combin_ontology_id: minimimumNonViability.combin_ontology_id,
                    mean_pod: minimimumNonViability.mean_pod,
                    mean_selectivity: minimimumNonViability.mean_selectivity,
                    n_values: minimimumNonViability.n_values,
                };
            })
            .value();
        //
        return plotData;
    }

    componentWillMount() {
        this.fetchBmdData(this.props.url);
    }

    UNSAFE_componentWillUpdate(nextProps) {
        if (nextProps.url !== this.props.url) {
            this.fetchBmdData(nextProps.url);
        }
    }

    _renderHelpText() {
        if (!this.state.showHelpText) {
            return null;
        }
        if (this.props.visualization === INTVIZ_HEATMAP) {
            return (
                <div className="alert alert-info">
                    <p>
                        Test substances are ranked from top to bottom (y-axis of the chart) by
                        lowest BMC (most active) to highest. The Use categories of test substances
                        are color coded next to each test substance name. If more than one
                        non-mortality endpoint was selected, the endpoint with the lowest BMC is
                        included. Each BMC for ranking is the median value of the BMC from the
                        triplicate testing and is shown as the colored dot. The range of lowest BMC
                        and the highest BMC is shown as the colored bar.
                    </p>
                    <br />

                    <p>
                        Additionally, the BMC values of the corresponding mortality (median, min and
                        max) are shown as the black dot and the black dashed line, respectively. If
                        the substance is inactive in either the non-mortality endpoints or the
                        mortality endpoint, no dots or bars will be shown.
                    </p>
                    <br />

                    <p>
                        The BMC values of all substances of the endpoint with the lowest median BMC
                        are listed below in tabular form (“-“ for inactive).
                    </p>
                </div>
            );
        } else {
            return (
                <div className="alert alert-info">
                    <p>
                        Specificity values for each test substance appear on the right-side of the
                        chart and are ranked by most to least specific. The use categories of test
                        substances are color coded next to each test substance name. The user can
                        select more than one non-mortality endpoint.
                    </p>
                    <br />
                    <p>
                        BMC value of the altered phenotype with the lowest summarized BMC among the
                        selected non-mortality endpoints is shown as the colored dot, and the
                        corresponding mortality (if active) is shown as the black dot (median) and
                        the black bar (min-max BMC). If the substance is inactive in either the
                        non-mortality endpoints or the mortality endpoint, no dots or bars will be
                        shown.
                    </p>
                    <br />

                    <p>
                        The BMC values of test substances with specific effect (default, but other
                        types can be toggled) listed below in tabular form (“-“ for inactive).
                    </p>
                </div>
            );
        }
    }

    render() {
        if (!this.state.data) {
            return <Loading />;
        }
        // let url = getBmdsUrl(this.state.assays, this.state.readouts);
        let chartName = this.props.visualization === BMDVIZ_ACTIVITY ? 'activity' : 'specificity',
            tableName =
                this.props.visualization === BMDVIZ_ACTIVITY
                    ? 'all chemicals'
                    : 'selected chemicals',
            title =
                this.props.visualization === BMDVIZ_ACTIVITY
                    ? 'More information on BMC by activity'
                    : 'More information on BMC by specificity',
            csvfileName =
                this.props.visualization === BMDVIZ_ACTIVITY
                    ? 'ActivityBMCData.csv'
                    : 'SpecificityBMCData.csv',
            csvfileHeader =
                this.props.visualization === BMDVIZ_ACTIVITY
                    ? [
                          {
                              title: 'dataset name (long)',
                              section: 'minimimumNonViability',
                              key: 'protocol_name_long',
                          },
                          {
                              title: 'dataset name (short)',
                              section: 'minimimumNonViability',
                              key: 'protocol_name_plot',
                          },
                          {
                              title: 'dtxsid',
                              section: 'minimimumNonViability',
                              key: 'dtxsid',
                          },
                          {
                              title: 'casrn',
                              key: 'casrn',
                          },
                          {
                              title: 'test substance',
                              key: 'preferred_name',
                          },
                          {
                              title: 'use category',
                              key: 'use_category1',
                          },
                          {
                              title: 'endpoint',
                              section: 'minimimumNonViability',
                              key: 'endpoint_name',
                          },
                          {
                              title: 'endpoint bmc (microM)',
                              method: 'processMedPodMed', // Function for processing med_pod_med
                              section: 'minimimumNonViability',
                              key: 'med_pod_med',
                          },
                          {
                              title: 'mortality bmc (microM)',
                              method: 'processMedPodMed', // Function for processing mort_med_pod_med
                              section: 'minimimumNonViability',
                              key: 'mort_med_pod_med',
                          },
                          {
                              title: 'lowest tested conc (microM)',
                              method: 'processMedPodMed', // Function for processing mort_med_pod_med
                              section: 'minimimumNonViability',
                              key: 'min_lowest_conc',
                          },
                          {
                              title: 'highest tested conc (microM)',
                              method: 'processMedPodMed', // Function for processing mort_med_pod_med

                              section: 'minimimumNonViability',
                              key: 'max_highest_conc',
                          },
                          {
                              title: 'n curves evaluated',
                              key: 'n_values',
                          },
                          {
                              title: 'n endpoints selected',
                              method: 'length', // Function for getting length of endpoint_names_list
                              section: 'minimimumNonViability',
                              key: 'endpoint_names_list',
                          },
                      ]
                    : [
                          {
                              title: 'dataset name (long)',
                              section: 'minimimumNonViability',
                              key: 'protocol_name_long',
                          },
                          {
                              title: 'dataset name (short)',
                              section: 'minimimumNonViability',
                              key: 'protocol_name_plot',
                          },
                          {
                              title: 'dtxsid',
                              section: 'minimimumNonViability',
                              key: 'dtxsid',
                          },
                          {
                              title: 'casrn',
                              key: 'casrn',
                          },
                          {
                              title: 'test substance',
                              key: 'preferred_name',
                          },
                          {
                              title: 'use category',
                              key: 'use_category1',
                          },
                          {
                              title: 'laboratory specific term',
                              section: 'minimimumNonViability',
                              key: 'malformation',
                          },
                          {
                              title: 'ontology term',
                              method: 'cat', // Function for getting length of endpoint_names_list
                              key: 'combin_ontology',
                          },
                          {
                              title: 'ontology id',
                              method: 'cat', // Function for getting length of endpoint_names_list
                              key: 'combin_ontology_id',
                          },
                          {
                              title: 'ontology term bmc (microM)',
                              method: 'processMedPodMed', // Function for getting length of endpoint_names_list
                              key: 'mean_pod',
                          },
                          {
                              title: 'developmental toxicity classification',
                              method: 'map', // Function for getting length of endpoint_names_list
                              section: 'minimimumNonViability',

                              key: 'final_dev_call',
                          },
                          {
                              title: 'mortality bmc (microM)',
                              method: 'processMedPodMed', // Function for processing mort_med_pod_med
                              section: 'minimimumNonViability',
                              key: 'mort_med_pod_med',
                          },
                          {
                              title: 'specificity',
                              key: 'mean_selectivity',
                          },
                          {
                              title: 'lowest tested conc (microM)',
                              method: 'processMedPodMed', // Function for processing mort_med_pod_med
                              section: 'minimimumNonViability',
                              key: 'min_lowest_conc',
                          },

                          {
                              title: 'highest tested conc (microM)',
                              method: 'processMedPodMed', // Function for processing mort_med_pod_med
                              section: 'minimimumNonViability',
                              key: 'max_highest_conc',
                          },

                          {
                              title: 'n curves evaluated',
                              key: 'n_values',
                          },
                          {
                              title: 'n endpoints selected',
                              method: 'length',
                              section: 'minimimumNonViability',
                              key: 'endpoint_names_list',
                          },
                      ],
            plotData = this._getFilteredData();
        return (
            <div>
                <h4 className={`label-horizontal label-normal`}>
                    BMC values: sorted by {chartName}
                    <HelpButtonWidget stateHolder={this} headLevel={'h2'} title={title} />
                </h4>
                {this._renderHelpText()}
                <div>
                    <h4 className={`label-normal`}>
                        <button
                            onClick={() => svg_download_form('BMC_heatmap01')}
                            className={`fa fa-camera pointer-button`}
                        ></button>
                        <span> Image</span>
                    </h4>
                </div>
                <RankedBarchart
                    data={plotData}
                    visualization={this.props.visualization}
                    selectedAxis={this.props.selectedAxis}
                    selectivityList={this.props.selectivityList}
                />
                <p className=" form-text">
                    <b>Interactivity note:</b> This chart is interactive. Click an item to view the
                    concentration-response curves from which the BMC was derived.
                </p>
                <div>
                    <h4 className={`label-horizontal  label-normal`}>
                        BMC for {tableName}
                        <HelpButtonWidget stateHolder={this} headLevel={'h2'} title={title} />
                    </h4>
                    <div>
                        <h4 className={`label-normal`}>
                            <button
                                onClick={() => exportCsv(plotData, csvfileName, csvfileHeader)}
                                className={`fa fa-download pointer-button`}
                            ></button>
                            <span> Data</span>
                        </h4>
                    </div>
                </div>

                {/*{this.props.visualization === BMDVIZ_ACTIVITY ? (<BmdTable data={plotData}/>) : (*/}
                {/*    <SelectivityTable data={plotData}/>)}*/}
                <BmdTable data={plotData} visualization={this.props.visualization} />
            </div>
        );
    }
}

RankedBarchartHandler.propTypes = {
    // selectedArray: PropTypes.string.isRequired,
    // selectedReadouts: PropTypes.array.isRequired,
    visualization: PropTypes.number.isRequired,
    selectivityCutoff: PropTypes.number.isRequired,
    selectivityList: PropTypes.array.isRequired,
    selectedAxis: PropTypes.number.isRequired,
    url: PropTypes.string.isRequired,
};

export default RankedBarchartHandler;
