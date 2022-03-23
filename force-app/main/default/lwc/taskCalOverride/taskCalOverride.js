import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import insertTaskLwc from "@salesforce/apex/MilestoneRecordPage.insertTaskLwc";
import { ShowToastEvent } from 'lightning/platformShowToastEvent'; 

export default class TaskCalOverride extends NavigationMixin(LightningElement) {
    @track task = {}
    filterContactLookup = ''
    disableBtn = false;
    
    get options() {
        return [
            { label: 'High', value: 'High' },
            { label: 'Normal', value: 'Normal' },
            { label: 'Low', value: 'Low' },
        ];
    }

    closeModal() {
        //mkt change-3
        // this.isMarketing=false;
        this.campaignName = null;
        this.activityStartDate = null;
        //alert('Navigate to cal');
        this.navigateCalendar();
    }
    handleDateChange(event) {
        this.task.StartDateTime__c = event.target.value;
    }
    handleCategoryChange(event) {
        this.task.Category__c = event.detail.selectedValue;

    }
    handleProductPicklistChange(event) {
        this.task.Product2__c = event.detail.selectedListData.join(';');
    }
    commentsChange(event) {
        this.task.Comments__c = event.target.value;
    }
    handleContactSelection(event) {
        this.task.Contact__c = event.detail;
        this.task.WhoId = event.detail;
    }
    addSupportSelection(event) {
        this.task.Support__c = event.detail.selectedValue;
    }
    handleAccountSelection(event) {
        let selectedAccount = event.detail;
        this.task.WhatId=selectedAccount;
        this.task.Account__c=selectedAccount;
        
        this.filterContactLookup = "accountid = '" + selectedAccount + "'";
    }
    handleInsert(event) {
        //alert('Insert call');
        this.task.reporting_for__c = 'Weekly';
        console.log('this.task::'+JSON.stringify(this.task));
        // saveTaskLwc({ records: this.myTaskList })
        //     .then((res) => {
        //         console.log(res);
        //     })
        //     .catch((err) => {
        //         console.log(err);
        //     });
        console.log('this.task.Product2__c::'+this.task.Product2__c);
        if(this.task.Product2__c == undefined || this.task.StartDateTime__c == undefined 
            || this.task.Comments__c == undefined || this.task.Category__c == undefined 
            || this.task.Contact__c == undefined || this.task.Account__c == undefined ||this.task.Priority == undefined){
            let msg ; 
            if(this.task.StartDateTime__c == undefined){
                msg = 'Start Date';    
            }else if(this.task.Category__c == undefined){
                msg = 'Type';
            }else if(this.task.Product2__c == undefined){
                msg = 'Product';
            }else if(this.task.Priority == undefined){
                msg = 'Priority';
            }else if(this.task.Comments__c == undefined){
                msg = 'Details';
            }else if(this.task.Account__c == undefined){
                msg = 'Hospital';
            }else if(this.task.Contact__c == undefined){
                msg = 'Contact';
            }
            this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Cannot Submit',
                        message: 'Please fill required fields - '+msg,
                        variant: 'info'
                    })
            );
            this.disableBtn = false;
            return;
        }else{
            insertTaskLwc({ record: this.task })
            .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                title: "Success",
                message: `Records saved succesfully!`,
                variant: "success"
                })
            );
            this.disableBtn = true;
            this.navigateCalendar();
            this.error = undefined;
            })
            .catch((error) => {
            this.error = error;
            console.log(this.error);
            this.record = undefined;
            this.dispatchEvent(
                new ShowToastEvent({
                title: "Error saving record",
                message: error.body.message,
                variant: "error"
                })
            );
            });

        }
    }
    navigateCalendar() {
       this[NavigationMixin.Navigate]({
           type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Event',
                actionName: 'home'
            }
        });
   }

   handleChangeTask(event) {
        this.task.Priority = event.target.value;
        console.log('this.task.Priority::'+this.task.Priority);
    }
}