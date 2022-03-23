import { api, LightningElement, track } from 'lwc';
import getUserList from '@salesforce/apex/MyTeamDailyTaskController.getUserList';
import fetchRecordsfromAccount from '@salesforce/apex/MyTeamDailyTaskController.fetchRecordsfromAccount';

export default class MyTeamAccountTasks extends LightningElement {

    @api recordId;
    @track defaultDate = new Date().toISOString().split('T')[0];                                                                
    @track selectedDate=this.defaultDate;
    @track teamUser=[
        { label: '--None--', value: "" },
    ];

    @track teamValues;
    @track userList=[];
    @track selectedUserId;
    @track myList=[];
    @track showSpinner = false;
    @track prodWidthStyle;

    connectedCallback(){
        console.log('record Id: '+this.recordId);

        this.prodWidthStyle ="width:"+parseInt(screen.width/6) +"px;";
        getUserList()
        .then(result => {                      
            
            console.log('result'+JSON.parse(JSON.stringify(result)));
            //this.userList = result; 
            for(let i=0;i<result.length;i++){
               // teamUser.push({label:userList[i].Name,value:userList[i].Id});
               console.log('name: '+result[i].Name);
               console.log('id: '+result[i].Id);
               this.teamUser=[...this.teamUser , {label:result[i].Name,value:result[i].Id}];
            }   
            console.log('picklist user'+this.teamUser);          
        })
        .catch(error => {
            this.error = error;
            this.record = undefined;
    });
    }

    handleDateChange(event) {
        this.selectedDate = event.target.value;
    }
    handleUserChange(event){
        console.log('user val: '+event.target.value);
        this.selectedUserId=event.target.value;
    }
    showTask(event){
        this.showSpinner = true;
        this.myList=[];
        console.log('record Id: '+this.recordId);
        fetchRecordsfromAccount({userId:this.selectedUserId,accountId:this.recordId})
        .then(result => {                     
            
            console.log('Task result: '+result);
            this.myList = result; 
            this.showSpinner = false;
            this.myList.forEach(element =>  {
                if(element.Product2__c ) {
                    element.Product2__c = element.Product2__c.replaceAll(';',',');
                }
            });                     
        })
        .catch(error => {
            this.error = error;
            this.record = undefined;
            console.log('err '+this.error);
            this.showSpinner = false;
        });
    }
}