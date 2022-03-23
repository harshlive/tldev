import { LightningElement, track ,wire,api} from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import COMPETITOR_FIELD from '@salesforce/schema/Metric__c.Competitor__c';
import getMonthlyCompInfo from '@salesforce/apex/competitorLWCController.getMonthlyCompInfo';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateMonthlyCompInfo from '@salesforce/apex/competitorLWCController.updateMonthlyCompInfo';
import getCompInfo from '@salesforce/apex/competitorLWCController.getCompInfo';

export default class CompetitorLWC extends LightningElement {
    
    @track compVal;
    @track monthVal;
    @api recordId;
    @track prodIdSet = [];
    @track fiscalYear ;
    @track curProdId;
    @track showAllData = false;
    @track showMonthlyData = false;
    @track updatedActualData;
    @track curActualData;
    @track currentRecordId;
    @track showSpinner = false;
    @track metricArray = [];
    @track dataBtnLabel = "See All Competitors' Data";
    @track showStencil = false;
    @track productLookupFilter = "Competitor_Product__c = true";
    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: COMPETITOR_FIELD })
    compPickVals;
    get monthOptions() {
        return [
            { label: 'JAN', value: 'JAN__c' },
            { label: 'FEB', value: 'FEB__c' },
            { label: 'MAR', value: 'MAR__c' },
            { label: 'APR', value: 'APR__c' },
            { label: 'MAY', value: 'MAY__c' },
            { label: 'JUN', value: 'JUN__c' },
            { label: 'JUL', value: 'JUL__c' },
            { label: 'AUG', value: 'AUG__c' },
            { label: 'SEP', value: 'SEP__c' },
            { label: 'OCT', value: 'OCT__c' },
            { label: 'NOV', value: 'NOV__c' },
            { label: 'DEC', value: 'DEC__c' },
        ];
    }
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

    compInputChange(event) {
        console.log(event.target.value);
        this.compVal = event.target.value;

        this.productLookupFilter = "Competitor_Product__c = true" + " AND Competitor__c = '"+this.compVal+"'"; 
    }
    getCompetitorInfo(event) { 
        if(event.target.label == "See All Competitors' Data") {
            this.showStencil = true;
        getCompInfo({accountId : this.recordId,
                    fiscal_year : this.fiscalYear} )
                .then(result => {
                    this.showStencil = false;
                    this.metricArray = [];
                    for(var i = 0;i<this.compPickVals.data.values.length ; i++) {
                        let itr = this.compPickVals.data.values[i];
                        let elem = result[itr.value];
                        if(elem) {
                            this.metricArray.push({competitor: itr.value,
                                products : elem,
                                rowspan : elem.length + 1});
                        }
                    }
                    this.dataBtnLabel = "Hide Data";
                    this.showAllData = true;
                })
                .catch(error => {
                    this.showStencil = false;
                    console.log(error);
                });
        }
        else if(event.target.label == "Hide Data") {
            this.dataBtnLabel = "See All Competitors' Data";
            this.showAllData = false;
        }
    }
    selectItemEventHandler(event){
        
        let args = JSON.parse(JSON.stringify(event.detail.arrItems));
        this.prodIdSet = [];
        args.map(element=>{
                    this.prodIdSet.push("'"+element.value+"'");
                });
        console.log(this.prodIdSet);
    }

    deleteItemEventHandler(event){
        let args = JSON.parse(JSON.stringify(event.detail.arrItems));
        this.prodIdSet = [];
        args.map(element=>{
                    this.prodIdSet.push("'"+element.value+"'");
                });
        console.log(this.prodIdSet);
    }
    connectedCallback() {
        console.log(this.recordId);
        this.fiscalYear = (new Date().getFullYear()+1).toString();
    }
    fyInputChange(event) {
        this.fiscalYear = event.detail.value;
    }
    handleProductSelection(event) {
        this.curProdId = event.detail;
    }
    // handleProductRemoval(event) {
    //     this.curProdId = undefined;
    // }
    monthInputChange(event) {
        this.monthVal = event.detail.value;
    }
    editCompInfo(event) {
        if(!this.compVal || !this.fiscalYear || !this.monthVal || !this.curProdId) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please fill all the data to fetch detail',
                    variant: 'Error'
                })
            );
            return;
        }
        this.showSpinner = true;
        getMonthlyCompInfo({accountId : this.recordId,
                            competitor : this.compVal,
                            fiscal_year : this.fiscalYear,
                            prodId : this.curProdId} )
        .then(result => {
            if(result != undefined) {
                console.log(result);
                this.curActualData = result[this.monthVal];
                this.showMonthlyData = true;
                this.currentRecordId = result.Id;
                console.log("Record Created with Id "+this.currentRecordId);
                this.showSpinner = false;
                
            }
            else {
                this.curActualData = 0;
                this.showSpinner = false;
                this.showMonthlyData = true;
                this.currentRecordId = undefined;
            }
        })
        .catch(error => {
            console.log(error);
        });
    }
    enableSave(event) {
        this.updatedActualData = event.target.value;
    }
    savecancelactual(event) {
        if(event.target.label == "Save") {
            this.showSpinner = true;
            let metric = {};
            metric.Id = this.currentRecordId;
            metric.Account__c = this.recordId;
            metric.Product__c = this.curProdId;
            metric.Metric_Type__c = 'Competitor Actuals (Current FY)';
            metric.Fiscal_Year__c = this.fiscalYear;
            metric.Competitor__c = this.compVal;
            let monthArray = [
                { label: 'JAN', value: 'JAN__c' },
                { label: 'FEB', value: 'FEB__c' },
                { label: 'MAR', value: 'MAR__c' },
                { label: 'APR', value: 'APR__c' },
                { label: 'MAY', value: 'MAY__c' },
                { label: 'JUN', value: 'JUN__c' },
                { label: 'JUL', value: 'JUL__c' },
                { label: 'AUG', value: 'AUG__c' },
                { label: 'SEP', value: 'SEP__c' },
                { label: 'OCT', value: 'OCT__c' },
                { label: 'NOV', value: 'NOV__c' },
                { label: 'DEC', value: 'DEC__c' },
            ];
            if(metric.Id === undefined) {
                monthArray.forEach(element => 
                    {
                        console.log(element);
                        if(element.value != this.monthVal) {
                            metric[element.value] = 0;
                        }
                    });
            }
            
            metric[this.monthVal] = this.updatedActualData;
            updateMonthlyCompInfo({metRecord : metric} )
                .then(result => {
                    this.showSpinner = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Information Updated',
                            variant: 'success'
                        })
                    );
                    this.showMonthlyData = false;
                    this.dataBtnLabel = "See All Competitors' Data";
                    this.showAllData = false;
                })
                .catch(error => {
                    this.showSpinner = false;
                    console.log(error);
                });
            
        }

        if(event.target.label == "Cancel") {
            this.showMonthlyData = false;
        }

    }

}