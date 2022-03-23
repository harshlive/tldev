import { LightningElement, track, wire, api } from 'lwc';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
//import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { CurrentPageReference } from 'lightning/navigation';
import getPickList from '@salesforce/apex/DailyReportingController.getPickList';

export default class AccountReasonForAcctRiskPicklist extends LightningElement {
    @wire(CurrentPageReference) pageRef;

    @api objectApiName;
    @api pickListfieldApiName;
    @api label;
    @api variant;

    /*only for lwc for mapping values in list and 
    also for mapping this with dependent picklist(give unique = record Id while using in dependent picklist)*/
    @api uniqueKey;

    @track value;
    recordTypeIdValue;

    @track options = [ ];  
    connectedCallback() {
        getPickList({objectName:'Account',fieldName:'Reason_for_account_being_at_risk__c'})
        .then(result => { 
            result.forEach(element => 
                this.options.push({label: element, value: element })
                ); 
        }
        )
        .catch(error => {
            this.error = error;
            console.log(this.error);
        })
    } 
    
    @api 
    get recordTypeId() { 
        return this.recordTypeIdValue;
    }
    set recordTypeId(value) {
        this.recordTypeIdValue = value; 
    }


    @api 
    get selectedValue() { 
        return this.value;
    }
    set selectedValue(val) { 
        if (val === '' || val === undefined || val === null)
            this.value = { label: '--None--', value: "" }.value;
        else
            this.value = val;
    }         

    
        
    handleChange(event) {
        let tempValue = event.target.value; 
        let selectedValue = tempValue;
        let key = this.uniqueKey;
        //Firing change event for aura container to handle
        //For Self
        const pickValueChangeEvent = new CustomEvent('picklistchange',{detail: { selectedValue, key } });
        this.dispatchEvent(pickValueChangeEvent);       
    }
    
}