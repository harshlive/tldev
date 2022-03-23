import AccountLookUp from '@salesforce/apex/LookupController.searchTeamAccounts';

import { api, LightningElement, track, wire } from 'lwc';


export default class customLookUp extends LightningElement {
    @api uniqueKey;
    @api objName;
    @api iconName;
    @api filter = '';
    @api label;
    @api searchPlaceholder='Search';
    @api selectedName;
    @track records;
    @api isValueSelected;
    @track blurTimeout;

    searchTerm;
    //css
    @track boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    @track inputClass = '';

    @wire(AccountLookUp, {searchTerm : '$searchTerm'})
    wiredRecords({ error, data }) {
        if (data) {
            this.error = undefined;
            this.records = data;
        } else if (error) {
            this.error = error;
            this.records = undefined;
        }
    }


    handleClick() {
        this.searchTerm = '';
        this.inputClass = 'slds-has-focus';
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus slds-is-open';
    }

    onBlur() {
        this.blurTimeout = setTimeout(() =>  {this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus'}, 300);
    }

    onSelect(event) {
        let selectedId = event.currentTarget.dataset.id;
        let selectedName = event.currentTarget.dataset.name;
        console.log('selected name'+event.currentTarget.dataset.name);
        let key = this.uniqueKey;
        if(key) {
            let selectedValue = selectedId;
            const valueSelectedEvent = new CustomEvent('lookupselected', {detail:  {selectedValue,key}});
            this.dispatchEvent(valueSelectedEvent);
            
        }
        else {
            const valueSelectedEvent = new CustomEvent('lookupselected', {detail:  selectedId });
            this.dispatchEvent(valueSelectedEvent);
        }
        
        
        this.isValueSelected = true;
        this.selectedName = selectedName;
        if(this.blurTimeout) {
            clearTimeout(this.blurTimeout);
        }
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    }

    @api handleRemovePill() {
        console.log('in remove')
        this.isValueSelected = false;
       this.searchTerm = '';
    }

    onChange(event) {
        this.searchTerm = event.target.value;
    }

}