import { LightningElement,api, track } from 'lwc';
import saveMetricRecord from '@salesforce/apex/TargetManagementController.saveMetricRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class MetricRows extends LightningElement {
    @api metricsLst;
    @track metricsMap=[];
    @track metricArray =[];
    //@track showSaveButton = false;
    @track metricRecordsList =[];
    @api accountId;
    @api fiscalYear;
    @api isEditEnabled = false;
    metricFieldMapping = {"m1":"APR__c",
                            "m2":"MAY__c",
                            "m3":"JUN__c",
                            "q1":"Q1_c",
                            "m4":"JUL__c",
                            "m5":"AUG__c",
                            "m6":"SEP__c",
                            "q2":"Q2__c",
                            "m7":"OCT__c",
                            "m8":"NOV__c",
                            "m9":"DEC__c",
                            "q3":"Q3__c",
                            "m10":"JAN__c",
                            "m11":"FEB__c",
                            "m12":"MAR__c",
                            "q4":"Q4_c",
                                }

    projectionsTypes = ["Actuals (Previous FY)","Actuals-Secondary (Current FY)",
    "Actuals-Primary (Current FY)", "Target (Current FY)"];

    async connectedCallback() {
        this.initializeCmp();
    }
    handleTargetChange(event) {
        this.showSaveButton = true;
        let currentTargetRecord = {'sobjectType': 'Metric__c',
                            'Metric__Type':'Target (Current FY)'};
        console.log(event);
        if(event.target.dataset) {
            if(event.target.dataset.id) {
                currentTargetRecord.Id = event.target.dataset.id;
                currentTargetRecord[this.metricFieldMapping[event.target.name]] = parseFloat(event.target.value);
                if(this.metricRecordsList[currentTargetRecord.Id]) {
                    this.metricRecordsList[currentTargetRecord.Id][this.metricFieldMapping[event.target.name]]= parseFloat(event.target.value);
                }
                else {
                    this.metricRecordsList[currentTargetRecord.Id] = currentTargetRecord;
                }
            }
        }
            this.isEventCalled = true;
            const enablesave = new CustomEvent('enablesave');
                this.dispatchEvent(enablesave);
        
        
    }
    
   @api saveTargets() {
        let reordList = [];
        saveMetricRecord({metricRecordList:Object.values( this.metricRecordsList)})
            .then(result => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Targets updated',
                        variant: 'success'
                    })
                   
                );
                //this.showSaveButton = false;
                const refreshAfterSaveEvent = new CustomEvent('savetarget');
                this.dispatchEvent(refreshAfterSaveEvent);
            })
            .catch(error => {
                console.log(error);
    });
    }
    // showSaveBtnFun(){
    //     this.showSaveButton = true;
    // }
    @api initializeCmp() {
        this.metricArray = [];
        this.metricsMap = [];
        for(var prod in this.metricsLst) {
            if(this.metricsLst[prod]) {
                for(var metricType in this.metricsLst[prod]) {
                    this.metricsMap.push({product:prod, 
                                            type:metricType,
                                            metric:this.metricsLst[prod][metricType],
                                            isEditable:metricType === "Target (Current FY)"? this.isEditEnabled:false})
                }
            }
        }
        console.log(this.metricsMap);

        let groupedDataMap = new Map();
        this.metricsMap.forEach(metricObj => {
            if (groupedDataMap.has(metricObj.product)) {
                groupedDataMap.get(metricObj.product).metricsObjs.push(metricObj);
            } else {
                let newMetricObj = {};
                newMetricObj.product = metricObj.product;
                newMetricObj.metricsObjs = [metricObj];
                groupedDataMap.set(metricObj.product, newMetricObj);
            }
        });

        let itr = groupedDataMap.values();
        let result = itr.next();
        while (!result.done) {
            result.value.rowspan = result.value.metricsObjs.length + 1;
            this.metricArray.push(result.value);
            result = itr.next();
        }
    }
}