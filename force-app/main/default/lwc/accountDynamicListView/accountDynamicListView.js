import { LightningElement, track, api } from 'lwc';
import fetchRecordsForWeeklyPlan from '@salesforce/apex/DailyReportingController.fetchRecordsForWeeklyPlan';
import fetchAccounts from '@salesforce/apex/AccountController.fetchAccounts';
import getAccDetails from '@salesforce/apex/DailyReportingController.getAccDetails';
import insertWeeklyTaskList from '@salesforce/apex/DailyReportingController.insertWeeklyTaskList';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'; 
import getPickListValues from "@salesforce/apex/DailyReportingController.getPickListValues";
import getPickList from "@salesforce/apex/DailyReportingController.getPickList";
//import showTaskList from "@salesforce/apex/DailyReportingController.showTaskList";
import FORM_FACTOR from "@salesforce/client/formFactor";
import saveAccountLWC from '@salesforce/apex/AccountController.saveAccountLWC';
import saveTaskLwc from "@salesforce/apex/MilestoneRecordPage.saveTaskLwc";
import { refreshApex } from '@salesforce/apex';
import USER_ID from '@salesforce/user/Id';

export default class WeeklyPlanning extends LightningElement {

    @track defaultDate = new Date().toISOString().split('T')[0];
    @track selectedAccount;
    @track showAccDetail = false;
    @track showTable = false;
    @track isModalOpen = false;
    @track showSpinner = false;
    @track myList=[];
    @track myTaskList=[];
    @track account=[];
    @track prodWidthStyle;
    @track variable = false;
    value ; 
    keyIndex = 0;

    @track categoryOptions = [];
    @track category;
    @track activityStartDate;
    @track statusOptions = [];
    @track status;
    @track product;
    @track filterContactLookup;
    accId;
    @track activityDate;
    @track priority;
    @track isEdited = false;
    @track toggleSaveLabel = "Save";
    @track dateIdList = [];
    @track commentsIdList = [];
    @track commentsChangedIdList = 1;
    errorFlag=false;

    connectedCallback(){
        this.prodWidthStyle ="width:"+parseInt(screen.width/6) +"px;";
        //task category
       
        
        this.fetchAccounts();
    }

    fetchAccounts(){
        this.showSpinner = true;
        console.log('11');
        fetchAccounts({userId:USER_ID})
            .then((result) => {
                this.myTaskList = result;
                //console.log("result"+ this.myTaskList);
               // console.log(this.myTaskList);
                this.myTaskList.forEach(ele=>{
                    console.log(ele.Name);
                })
                this.error = undefined;
                if (this.isEdited == true) {
                this.isEdited = false;
                }
            })
            .catch((error) => {
                this.error = error;
                this.record = undefined;
            });
            setTimeout(() => {
            if (FORM_FACTOR == "Small") {
                this.template
                .querySelector('[data-id="myTaskListTable"]')
                .classList.add("formFactorSmall");
            } else if (FORM_FACTOR == "Large") {
                this.template
                .querySelector('[data-id="myTable"]')
                .classList.add(".slds-max-medium-table--stacked");
            }
            }, 300); 
        console.log('22');

    }
   

    handleDateChange(event) {
        this.dateVal = event.target.value;
        console.log('nnn');
        var uniqueKey = event.target.dataset.id;
        let tempList  = JSON.parse(JSON.stringify(this.myList)); 
        tempList.map(e =>{
            console.log('e.uniKey::'+e.uniKey);
            console.log('uniqueKey::'+uniqueKey);

            if(e.uniKey === uniqueKey){
                e.StartDateTime__c = this.dateVal;
            console.log('e.StartDateTime__c::'+e.StartDateTime__c);
            }
        })  
        this.myList = tempList;
    }

 

    // addCategoryChange(event) {
    // this.category = event.detail.value;
    // }

    // dateChange(event) {
    // this.activityStartDate = event.target.value;
    // }

    // addStatusChange(event) {
    // this.status = event.detail.value;
    // }

    // commentsChange(event) {
    // this.comments = event.target.value;
    // }


    onDoubleClickEdit() {
        this.isEdited = true;
    }
   
   handleSave() {
        this.toggleSaveLabel = "Saving...";
         this.errorFlag=false;
        this.dateIdList.sort(function (a, b) {
        if (a > b) return 1;
        if (a < b) return -1;
        return 0;
        });
        this.commentsIdList.sort(function (a, b) {
        if (a > b) return 1;
        if (a < b) return -1;
        return 0;
        });

        let dateCount = this.dateIdList.filter(
        (a, b) => this.dateIdList.indexOf(a) === b
        );
        let commentCount = this.commentsIdList.filter(
        (a, b) => this.commentsIdList.indexOf(a) === b
        );

        for (var i = 0; i < dateCount.length; i++) {
        if (
            this.myTaskList.some(
            (account) =>
            account.Id === dateCount[i] &&
            account.Deadline_for_action__c != undefined &&
                (account.Deadline_for_action__c.trim() === "" ||
                account.Deadline_for_action__c === null)
            )
        ) {
            commentCount = commentCount.filter((item) => item !== dateCount[i]);
        }
        }

        if (commentCount.length == dateCount.length) {
                let toSaveList = this.myTaskList;
                toSaveList.forEach((element, index) => {
                    if (element.Subject === "") {
                    toSaveList.splice(index, 1);
                    }
                });

                this.myTaskList = toSaveList;
                console.log("save LWC");
                console.log(" this.myTaskList::"+JSON.stringify(this.myTaskList));
                this.myTaskList.forEach((elem, index) => {
                    console.log(this.errorFlag);
                    
                    if(elem.Action_Plan_for_account__c=="" || elem.Critical_Success_Factor_for_Aim__c=="" || elem.Deadline_for_action__c==null
                               || elem.Product_Category__c=="" || elem.Product_Category__c==undefined  || elem.Aim_in_Account__c==undefined
                               || elem.Action_Plan_for_account__c==undefined || elem.Critical_Account__c==undefined || elem.Deadline_for_action__c==undefined ){
                    this.errorFlag=true;
                    console.log(this.errorFlag);
                    }
                    console.log(this.errorFlag);
                    console.log(elem); // the elment
                    console.log(index); // the index in the NodeList
                });

                if(this.errorFlag){
                    this.dispatchEvent(
                        new ShowToastEvent({
                        title: "Error for saving Record",
                        message: `Please Enter all Required  Fields`,
                        variant: "error"
                        })
                    );
                    this.toggleSaveLabel = "Save";
                }
                if(!this.errorFlag){
                saveAccountLWC({ records: this.myTaskList })
                    .then(() => {
                    this.toggleSaveLabel = "Saved";

                    this.dispatchEvent(
                        new ShowToastEvent({
                        title: "Success",
                        message: `Records saved succesfully!`,
                        variant: "success"
                        })
                    );
                    console.log(" get rec");

                    this.isEdited = false;
                    //this.getTaskRecords();
                    console.log("after get rec");
                    this.dateIdList = [];
                    this.commentsIdList = [];

                    console.log("edit true");
                    //this.isEdited = false;

                    console.log("edit false");
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
                    })
                    .finally(() => {
                    setTimeout(() => {
                        this.toggleSaveLabel = "Save";
                    }, 3000);
                    });
                }
        } else {
            this.toggleSaveLabel = "Save";

            let filterRows = dateCount.filter((a) => !commentCount.includes(a));

            let allOutcomes = this.template.querySelectorAll(".slds-show");

            for (var i = 0; i < filterRows.length; i++) {
                const selectedRowId = filterRows[i];
                for (var i = 0; i < allOutcomes.length; i++) {
                let outcomeCells = allOutcomes[i].dataset.id;
                if (outcomeCells == selectedRowId) {
                    //allOutcomes[i].classList.remove('slds-hide');
                    allOutcomes[i].classList.add("slds-text-color_error");
                    break;
                }
                }
            }
        }
    }

    handleCancel() {
        console.log("cancel");
        this.isEdited = false;
        console.log(this.isEdited);
        this.toggleSaveLabel = "Save";

        this.dateIdList = [];
        this.commentsIdList = [];
        

        //this.getTaskRecords();
    }


    handleDateChangeTask(event) {
        let element = this.myTaskList.find((ele) => ele.Id === event.target.dataset.id);
        let tempList = JSON.parse(JSON.stringify(this.myTaskList));
        tempList.map((e) => {
        if (e.Id === event.target.dataset.id) {
            console.log('defaut date '+this.defaultDate);
            if(event.target.value > this.defaultDate){
                e.Deadline_for_action__c = event.target.value;
            }   
        }
        });
        
        this.myTaskList = tempList;

        // this.datechangedIdList++;
        // this.dateIdList.push(event.target.dataset.id);

        // let allOutcomes = this.template.querySelectorAll(".slds-hide");
        // const selectedRowId = event.target.dataset.id;
        // for (var i = 0; i < allOutcomes.length; i++) {
        //     let outcomeCells = allOutcomes[i].dataset.id;

        //     if (outcomeCells == selectedRowId) {
        //         allOutcomes[i].classList.remove("slds-hide");
        //         allOutcomes[i].classList.add("slds-show");
        //         break;
        //     }
        // }
    }

    handleAccountDynamicsChangeTask(event) {
        let element = this.myTaskList.find((ele) => ele.Id === event.target.dataset.id);
        let tempList = JSON.parse(JSON.stringify(this.myTaskList));
        tempList.map((e) => {
        if (e.Id === event.target.dataset.id) {
            e.Account_Dynamics__c = event.target.value;
        }
        });
        this.myTaskList = tempList;
        // let eventData = event.detail;
        // let pickValue = event.detail.selectedValue;
        // let uniqueKey = event.detail.key;
        // let element = this.myTaskList.find((ele) => ele.Id === uniqueKey);
        // let tempList = JSON.parse(JSON.stringify(this.myTaskList));
        // tempList.map((e) => {
        // if (e.Id === uniqueKey) {
        //     e.Account_Dynamics__c = pickValue;
        // }
        // });
        // this.myTaskList = tempList;
    }
    handleCriticalSuccessFactor(event){
        event.stopPropagation();
        const detail = event.detail.selectedListData;
        const key = event.detail.key;
        let criticalPicklistVal = "";
        if (detail.length > 0) {
        criticalPicklistVal = detail.join(";");
        let tempList = JSON.parse(JSON.stringify(this.myTaskList));
        tempList.map((e) => {
            if (e.Id === key) {
            e.Critical_Success_Factor_for_Aim__c = criticalPicklistVal;
            }
        });
        this.myTaskList = tempList;
        }
        if (detail.length === 0) {
        let tempList = JSON.parse(JSON.stringify(this.myTaskList));
        tempList.map((e) => {
            if (e.Id === key) {
            e.Critical_Success_Factor_for_Aim__c = "";
            }
        });
        this.myTaskList = tempList;
        }
    }

    handleActionPlan(event) {
        let element = this.myTaskList.find((ele) => ele.Id === event.target.dataset.id);
        let tempList = JSON.parse(JSON.stringify(this.myTaskList));
        tempList.map((e) => {
        if (e.Id === event.target.dataset.id) {
            e.Action_Plan_for_account__c = event.target.value;
        }
        });
        this.myTaskList = tempList;
        //element.Subject = event.target.value;
        //this.myTaskList = [...this.myTaskList];
    }
    handleCriticalAccount(event) {
        let element = this.myTaskList.find((ele) => ele.Id === event.target.dataset.id);
        let tempList = JSON.parse(JSON.stringify(this.myTaskList));
        tempList.map((e) => {
            console.log('in criticalHadle');
            console.log('critical value '+event.target.value);
        if (e.Id === event.target.dataset.id) {
            e.Critical_Account__c = event.target.checked;
        }
        });
        this.myTaskList = tempList;
        //element.Subject = event.target.value;
        //this.myTaskList = [...this.myTaskList];
    }


    handleAimInAccount(event) {
        let eventData = event.detail;
        let pickValue = event.detail.selectedValue;
        console.log('pickvalue'+pickValue );
        let uniqueKey = event.detail.key;
        let element = this.myTaskList.find((ele) => ele.Id === uniqueKey);
        let tempList = JSON.parse(JSON.stringify(this.myTaskList));
        tempList.map((e) => {
        if (e.Id === uniqueKey) {
            e.Aim_in_Account__c = pickValue;
            console.log('e.Aim_in_Account__c::'+e.Aim_in_Account__c);
        }
        });
        this.myTaskList = tempList;
    }

    handleProductFamily(event){

         let eventData = event.detail;
        let pickValue = event.detail.selectedValue;
        console.log('pickvalue'+pickValue );
        let uniqueKey = event.detail.key;
        let element = this.myTaskList.find((ele) => ele.Id === uniqueKey);
        let tempList = JSON.parse(JSON.stringify(this.myTaskList));
        tempList.map((e) => {
        if (e.Id === uniqueKey) {
            e.Product_Category__c = pickValue;
            console.log('e.Product_Category__c::'+e.Product_Category__c);
        }
        });
        this.myTaskList = tempList;
    }

    handleReasonforAcct(event) {


        const detail = event.detail.selectedListData;
        const key = event.detail.key;
        let criticalPicklistVal = "";
        if (detail.length > 0) {
        criticalPicklistVal = detail.join(";");
        let tempList = JSON.parse(JSON.stringify(this.myTaskList));
        tempList.map((e) => {
            if (e.Id === key) {
            e.Reason_for_account_being_at_risk__c = criticalPicklistVal;
            }
        });
        this.myTaskList = tempList;
        }
        if (detail.length === 0) {
        let tempList = JSON.parse(JSON.stringify(this.myTaskList));
        tempList.map((e) => {
            if (e.Id === key) {
            e.Reason_for_account_being_at_risk__c = "";
            }
        });
        this.myTaskList = tempList;
        }







        // let eventData = event.detail;
        // let pickValue = event.detail.selectedValue;
        // let uniqueKey = event.detail.key;
        // let element = this.myTaskList.find((ele) => ele.Id === uniqueKey);
        // let tempList = JSON.parse(JSON.stringify(this.myTaskList));
        // tempList.map((e) => {
        // if (e.Id === uniqueKey) {
        //     e.Reason_for_account_being_at_risk__c = pickValue;
        // }
        // });
        // this.myTaskList = tempList;
    }

    handleIsAcctRisk(event){
        let element = this.myTaskList.find((ele) => ele.Id === event.target.dataset.id);
        let tempList = JSON.parse(JSON.stringify(this.myTaskList));
        tempList.map((e) => {
            console.log('in account at risk');
            console.log(' account at risk '+event.target.value);
        if (e.Id === event.target.dataset.id) {
            e.Is_Account_at_Risk__c = event.target.checked;
        }
        });
        this.myTaskList = tempList;
    }
}