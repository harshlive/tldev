import { LightningElement, track, api, wire } from 'lwc';
import getMileStone from '@salesforce/apex/MilestoneRecordPage.getMileStone';
//import NAME_FIELD  from '@salesforce/schema/Milestone__c.Name';
//import COMPLETION_DATE_FIELD from '@salesforce/schema/Milestone__c.Completion_Date__c';
export default class Milestone extends LightningElement {

    @api milestoneId;
    @track milestones;
    @api showTask=false;
    @wire(getMileStone,{ milestoneId: '$milestoneId' }) 

  // fields = [NAME_FIELD ,Completion_Date ];

    milestoneData({error,data}){
        if (data) {
            this.milestones = data;
 
        } else if (error) {
 
            this.error = error;
 
        }
    }
    handleSubmit(event) {
        console.log(event.detail);
    }
    handleSuccess(event) {
        console.log('Record Updated'); 
    }
    viewTask(event){
        this.showTask=true;
    }
    
    @api showMilestone=false;

    constructor(){
        super();
        this.showMilestone=true;
    }

}