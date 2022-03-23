import { LightningElement, track ,wire} from 'lwc';
import getIndices from '@salesforce/apex/IndexationLWCController.getIndices';
import saveIndex from '@salesforce/apex/IndexationLWCController.saveIndex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import STATE_FIELD from '@salesforce/schema/Index_Factor__c.State__c';

export default class IndexationLWC extends LightningElement {

    @track fiscalYear;
    @track stateVal;
    @track currentIndexRecord;
    @track showIndices = false;
    @track showError = false;
    @track showSpinner = false;
    @track errorMessage;
    @track stateOptions = [];
    @track editEnabled = false;
    @track updatedIndex = {};

    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: STATE_FIELD })
    statePickVals;

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
        this.fiscalYear = (new Date().getFullYear()+1).toString();
    }
    fyInputChange(event) {
        this.fiscalYear = event.detail.value;
    }
    stateInputChange(event) {
        this.stateVal = event.detail.value;
    }
    getIndices() {
        if(!this.stateVal) {
            this.errorMessage = "Please enter State to proceed";
            this.showError = true;
            return
        }
        console.log("Fetch index data for year "+this.fiscalYear + " and State "+this.stateVal);
        if(this.fiscalYear && this.stateVal) {
            this.showError = false;
            this.showSpinner = true;
            getIndices({state:this.stateVal,
                fiscalYear:this.fiscalYear,
            })
            .then(result => {
                this.currentIndexRecord = result;
                this.showSpinner = false;
                this.showIndices = true;
                this.saveEnabled = false;
                this.editEnabled = false;
            })
            .catch(error => {
                this.errorMessage = "An error has occured. Please try again";
                this.showError = true;
                this.showSpinner = false;
                console.log(error);
            });
        }
    }
    handleSave() {
        this.showSpinner = true;
        this.showIndices = false;
        this.currentIndexRecord.Q1_Index__c = this.updatedIndex.Q1_Index__c;
        this.currentIndexRecord.Q2_Index__c = this.updatedIndex.Q2_Index__c;
        this.currentIndexRecord.Q3_Index__c = this.updatedIndex.Q3_Index__c;
        this.currentIndexRecord.Q4_Index__c = this.updatedIndex.Q4_Index__c;
        saveIndex({index:this.currentIndexRecord})
        .then(result => {
            this.currentIndexRecord = result;
            this.showSpinner = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Targets Updated for Hospitals in '+ this.stateVal,
                    variant: 'success'
                })
            );
            this.showIndices = false;
            this.saveEnabled = false;
            this.editEnabled = false;

        })
        .catch(error => {
            this.errorMessage = "An error has occured. Please try again";
            this.showError = true;
            this.showSpinner = false;
            console.log(error);
        });
    }
    cancelSave() {
        this.saveEnabled = false;
        this.editEnabled = false;
    }
    enableEdit() {
        this.saveEnabled = true;
        this.editEnabled = true;
    }
    handleIndexUpdate(event) {
        if(event.target.name == "q1_input") {
            this.updatedIndex.Q1_Index__c	= event.target.value;
        }
        if(event.target.name == "q2_input") {
            this.updatedIndex.Q2_Index__c	= event.target.value;
        }
        if(event.target.name == "q3_input") {
            this.updatedIndex.Q3_Index__c	= event.target.value;
        }
        if(event.target.name == "q4_input") {
            this.updatedIndex.Q4_Index__c	= event.target.value;
        }
    }
}