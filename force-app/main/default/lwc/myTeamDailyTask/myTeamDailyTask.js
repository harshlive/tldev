import { LightningElement, track } from 'lwc';


import getUserList from '@salesforce/apex/MyTeamDailyTaskController.getUserList';
import fetchRecords from '@salesforce/apex/MyTeamDailyTaskController.fetchDailyRecords';

export default class MyTeamDailyTask extends LightningElement {

    @track defaultDateTo = new Date().toISOString().split("T")[0];
    @track defaultDateFrom = new Date().toISOString().split("T")[0];
    @track selectedFromDate = this.defaultDateFrom;
    @track selectedToDate = this.defaultDateTo;
    //remove
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
    //new
    handleFromDateChange(event) {
        this.selectedFromDate = event.target.value;
    }
    handleToDateChange(event) {
    this.selectedToDate = event.target.value;
    }
    //remove
    handleDateChange(event) {
        this.selectedDate = event.target.value;
    }
    handleUserChange(event){
        console.log('user val: '+event.target.value);
        this.selectedUserId=event.target.value;
    }
    showTask(event){
        this.showSpinner = true;
        fetchRecords({
            userId: this.selectedUserId,
            fromDate: this.selectedFromDate,
            toDate: this.selectedToDate
          })
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