import { LightningElement, track, api, wire } from 'lwc'; 
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getOutcomeList from '@salesforce/apex/MilestoneRecordPage.getOutcomeList';
import deleteOutcome from '@salesforce/apex/MilestoneRecordPage.deleteOutcome';
import insertOutcome from '@salesforce/apex/MilestoneRecordPage.insertOutcome'; 
import saveOutcomeLwc from '@salesforce/apex/MilestoneRecordPage.saveOutcomeLwc';
import FORM_FACTOR from '@salesforce/client/formFactor';
import getProfileInfo from '@salesforce/apex/MilestoneRecordPage.getProfileInfo';
import getOutcomeMaster from '@salesforce/apex/MilestoneRecordPage.getOutcomeMaster';
import USER_ID from '@salesforce/user/Id';
  
export default class ShowOutcomeTile extends LightningElement {
    
    @track showTask;
    @api milestoneId;
    @track isEdited = false;
    @track toggleSaveLabel = 'Save';
    @track myList=[];
    @api outcomeId;
    @api accId;
     
 
    /*--------------------Mapping field values to the list onchange START --------------------*/   
     @track formFactorSmall=false;
     @track showDelete=false; 
     @track outcomeOptions=[];

    //  get outcomeOptions() {
    //     return [
    //         { label: 'New', value: 'New' }, 
    //     ];
    // } 
    connectedCallback(){

        getProfileInfo({userId : USER_ID}).
        then(result => {                
            console.log(result);              
             if(result=='ZSM'||result=='System Administrator'){
                this.showDelete=true;
             }
        })
        console.debug('form factor:');
        console.debug('form:'+FORM_FACTOR);
        if(FORM_FACTOR=='Small'){
            this.formFactorSmall=true;
        }
        this.getOutcomeRecords();
        
      
    }

    getOutcomeRecords() { 
        let formfactor=FORM_FACTOR; 
        getOutcomeList({milestoneId :this.milestoneId})  
            .then(result => {                      
                this.myList = result; 
                console.log('acc'+this.myList[0].Account__c);
                this.accId=this.myList[0].Account__c;
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.record = undefined;
        });
        getOutcomeMaster({guidanceId :this.milestoneId})
            .then(result => {    
                console.log('1'+result);     
                this.error = undefined;
                if (result) {
                    for(var i =0 ; i<result.length ; i++){
                        
                        console.log('c: '+result[i].Name);                           
                         
                            this.outcomeOptions.push({value: result[i].Name , 
                                label: result[i].Name })
                    } 
                }
            })
            .catch(error => {
                this.error = error;
                this.record = undefined;
        }); 
        setTimeout(() => { 
        if(FORM_FACTOR=='Small'){ 
            this.template.querySelector('[data-id="myListTable"]').classList.add('formFactorSmall');
        }else if(FORM_FACTOR=='Large'){  
            this.template.querySelector('[data-id="myTable"]').classList.add('.slds-max-medium-table--stacked');
        }},1500);

    }             
     
    handleDueDate(event) {
        let element = this.myList.find(ele  => ele.Id === event.target.dataset.id); 
        let tempList  = JSON.parse(JSON.stringify(this.myList));
        tempList.map(e =>{
            if(e.Id === event.target.dataset.id){
                e.Due_Date__c = event.target.value;
            }
        }) 
        this.myList = tempList;  
    }
    handleCompletionDate(event) {
        let element = this.myList.find(ele  => ele.Id === event.target.dataset.id); 
        let tempList  = JSON.parse(JSON.stringify(this.myList));
        tempList.map(e =>{
            if(e.Id === event.target.dataset.id){
                e.Completion_Date__c = event.target.value;
            }
        }) 
        this.myList = tempList; 
    }
    handleDescription(event) { 
        let element = this.myList.find(ele  => ele.Id === event.target.dataset.id); 
        let tempList  = JSON.parse(JSON.stringify(this.myList));
        tempList.map(e =>{
            if(e.Id === event.target.dataset.id){
                e.Description__c = event.target.value;
            }
        }) 
        this.myList = tempList;  
    }
     
    handleStatusChange(event) { 
        let eventData = event.detail; 
        let pickValue = event.detail.selectedValue; 
        let uniqueKey = event.detail.key; 
        let element = this.myList.find(ele  => ele.Id === uniqueKey);  
        let tempList  = JSON.parse(JSON.stringify(this.myList)); 
        tempList.map(e =>{
            if(e.Id === uniqueKey){
                e.Status__c = pickValue;
            }
        }) 
        this.myList = tempList; 
    }
      
    //@api call
    async showOutTasks(event){
        
        const selectedRowId = event.currentTarget.dataset.id;  
        let allOutcomes = this.template.querySelectorAll('tr');
        for(var i =1 ; i<allOutcomes.length ; i++) {
            allOutcomes[i].classList.remove('slds-is-selected')
        }
        for(var i =1 ; i<allOutcomes.length ; i++) {

            let outcomeCells = allOutcomes[i].cells;
                if(outcomeCells[0].dataset.id == selectedRowId || 
                    outcomeCells[outcomeCells.length-1].dataset.id == selectedRowId) {
                    allOutcomes[i].classList.add('slds-is-selected');
                    break;
                }
        }        
        this.outcomeId = selectedRowId;

        this.showTask=true; 
        setTimeout(() => {
            let childTask = this.template.querySelector('c-show-tasks-tile');         childTask.outcomeId = this.outcomeId;
            childTask.getTaskRecords();              
        }, 200);      

    }

    async showSelectionTask(event){ 
        const selectedRowId = event.detail.selectedRows[0].Id;        
        this.recordsCount = event.detail.selectedRows.length;
        // this set elements the duplicates if any
        let conIds=[];  
        this.outcomeId = selectedRowId;
        this.showTask=true;          
         let childTask = this.template.querySelector('c-show-tasks-tile');
         //childTask.outcomeId = this.outcomeId;
         childTask.getTaskRecords();          
    }

    /*--------------------Mapping field values to the list onchange END --------------------*/    
    @track isModalOpen = false;
    openModal() {
         this.isModalOpen = true;
    }
    closeModal() {
         this.isModalOpen = false; 
    }
    submitDetails() {
         this.isModalOpen = false;
    }

       
    @track status; 
    get statusOptions() {
        return [
            { label: '--None--', value: '' },
            { label: 'Not Started', value: 'Not Started' },
            { label: 'In Progress', value: 'In Progress' },
            { label: 'Complete', value: 'Complete' },
            { label: 'Not Applicable', value: 'Not Applicable'},
        ];
    } 
    addStatusChange(event) {
        this.status = event.detail.value; 
    }
    addOutcomeOptionsChange(event){
        
        this.description = event.detail.value; 

    }
      
     
    @track dueDate;
    dueDateChange(event){
        this.dueDate=event.target.value;
    }    
    @track description;
    descripitionChange(event) {
        this.description = event.detail.value; 
    }
    @track completiondate;
    completionDateChange(event) {
        this.completiondate = event.detail.value; 
    }
 
    handleinsert(event){
        this.template.querySelectorAll('lightning-input-field').forEach(element => {
            element.reportValidity();
        }); 
        let outcomeSave = { 'sobjectType': 'Outcome__c' };  
        outcomeSave.Due_Date__c=this.dueDate;
        outcomeSave.Completion_Date__c=this.completiondate;
        outcomeSave.Status__c=this.status;
        outcomeSave.Description__c=this.description;   
        outcomeSave.Milestone__c=this.milestoneId;
 
        insertOutcome({newOutcome: outcomeSave})
        .then(result=>{ 
            this.description = null;
            this.startDate=null;
            this.dueDate=null;
            this.completiondate=null;
            this.status=null;

            this.isModalOpen=false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Outcome inserted',
                    variant: 'success'
                })
            );
            this.getOutcomeRecords(); 
        })
        .catch(error => {
            console.log(error);
            this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error saving record',
                            message: error.body.message,
                            variant: 'error'
                        })
                );
        });
    }
 

    remove(event) {  
        //let indexPosition = event.currentTarget.name;
        const recId = event.currentTarget.dataset.id;
                
        deleteOutcome({toDeleteId : recId})
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title : 'Success',
                    message : `Record deleted succesfully!`,
                    variant : 'success',
                }),
            )

            if(this.myList.length > 1) 
            this.getOutcomeRecords();
            this.myList.splice(indexPosition, 1);
            this.error = undefined;
        })
        .catch(error => {
            this.error = error;
        })
    }

    handleOutcomeSave() {
        console.log('Save Handle');
        this.toggleSaveLabel = 'Saving...';
        let toSaveList = this.myList;
        toSaveList.forEach((element, index) => {
            if(element.Subject === ''){
                toSaveList.splice(index, 1);
            }
        });

        this.myList = toSaveList; 

        saveOutcomeLwc({records : this.myList})
        .then(() => {
            this.toggleSaveLabel = 'Saved';            
            this.dispatchEvent(
                new ShowToastEvent({
                    title : 'Success',
                    message : `Records saved succesfully!`,
                    variant : 'success',
                }),
            ) 
            this.getOutcomeRecords();          
            this.isEdited = false;
            this.error = undefined;
        })
        .catch(error => {
             
            console.log(error);
            this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error saving record',
                            message: error.body.message,
                            variant: 'error'
                        })
                );
        })
        .finally(() => {

            setTimeout(() => {
                this.toggleSaveLabel = 'Save';                
            }, 3000);
            
            
        });
    }

     
    onDoubleClickEdit() {
        this.isEdited = true;
    }

    handleCancel() {
        
        this.getOutcomeRecords();  
        this.isEdited = false;
    }
}