import { LightningElement,track, api } from 'lwc';
import fetchMetrics from '@salesforce/apex/TargetManagementController.fetchMetrics';
export default class TargetManagement extends LightningElement {
    @track accountId;
    @api productId;
    @track fiscalYear;
    @api metricsLst;
    @api recordId;
    @track prodIdSet = [];
    @track showSpinner = false;
    @track showMetrics = false;
    @track isEditBtnEnabled = false;
    @track enableSaveCancel = false;
    //Added to hide Edit Targets Option
    @track disableEditTargets = false;
    get fyOptions() {
        return [
            { label: '2019', value: '2019' },
            { label: '2020', value: '2020' },
            { label: '2021', value: '2021' },
            { label: '2022', value: '2022' },
            { label: '2023', value: '2023' },
            { label: '2024', value: '2024' },
            { label: '2025', value: '2025' },
            { label: '2026', value: '2026' },
            { label: '2027', value: '2027' },
            { label: '2028', value: '2028' },
            { label: '2029', value: '2029' },
            { label: '2030', value: '2030' },
        ];
    }

    connectedCallback() {
    //     this.showSpinner = true;
        this.fiscalYear = (new Date().getFullYear()+1).toString();

    //     fetchMetrics({accountId:this.recordId,
    //         fy:this.fiscalYear
    //         })
    // .then(result => {
    //     this.metricsLst = result;
    //     console.log(this.metricsLst);
        
    //     this.showMetrics = true;
    // })
    // .catch(error => {
    //     console.log(error);
    // });
    }
    enableSave(){
        //this.editBtnLabel = "Save Targets"
        this.isEditBtnEnabled = false;
        this.enableSaveCancel = true;
    }
    editsavecancelTargets(event) {
        if(event.target.label == "Edit Targets") {
            let metricsCmp = this.template.querySelector('c-metric-rows');
            metricsCmp.isEditEnabled = true;
            metricsCmp.initializeCmp();
        }
        else if(event.target.label == "Save") {
            let metricsCmp = this.template.querySelector('c-metric-rows');
            metricsCmp.saveTargets();
        }
        else if(event.target.label == "Cancel") {
            let metricsCmp = this.template.querySelector('c-metric-rows');
            metricsCmp.isEditEnabled = false;
            metricsCmp.initializeCmp();
            this.isEditBtnEnabled = true;
            this.enableSaveCancel = false;
        }
        
    }
    handleProductSelection(event){
        console.log("the account record id is"+event.detail);
        this.productId = event.detail;
    }
    fyInputChange(event) {
        //console.log("the fy value is"+event.target.value + ' and field name is ' + event.detail.name);
        this.fiscalYear = event.detail.value;
    }
    fetchTargets() {
        console.log(this.prodIdSet);
        this.showMetrics = false;
        this.showSpinner = true;
        fetchMetrics({accountId:this.recordId,
                    fy:this.fiscalYear,
                    productIdSet:this.prodIdSet.length>0 ? '('+ this.prodIdSet.join(',') + ')' : '*'
                })
            .then(result => {
                this.metricsLst = result;
                console.log(this.metricsLst);
                this.showSpinner = false;
                this.showMetrics = true;
                this.enableSaveCancel = false;
                this.isEditBtnEnabled = true;
            })
            .catch(error => {
                console.log(error);
            });
    }

    selectItemEventHandler(event){
        if(this.showSpinner == true) {
            this.showSpinner = false;
        }
        let args = JSON.parse(JSON.stringify(event.detail.arrItems));
        this.prodIdSet = [];
        args.map(element=>{
                    this.prodIdSet.push("'"+element.value+"'");
                });
    }

    deleteItemEventHandler(event){
        let args = JSON.parse(JSON.stringify(event.detail.arrItems));
        this.prodIdSet = [];
        args.map(element=>{
                    this.prodIdSet.push("'"+element.value+"'");
                });
    }

    }