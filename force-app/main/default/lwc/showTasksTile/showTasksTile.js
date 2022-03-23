import { LightningElement, track, api, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import showTaskList from "@salesforce/apex/MilestoneRecordPage.showTaskList";
import deleteTask from "@salesforce/apex/MilestoneRecordPage.deleteTask";
import insertTask from "@salesforce/apex/MilestoneRecordPage.insertTask";
import saveTaskLwc from "@salesforce/apex/MilestoneRecordPage.saveTaskLwc";
//import 'c/showTasksTile'

//mkt change
//import fetchCampaign from '@salesforce/apex/DailyReportingController.fetchCampaign';
import setReminder from "@salesforce/apex/MilestoneRecordPage.setReminder";
import getPickList from "@salesforce/apex/DailyReportingController.getPickList";

import getPickListValues from "@salesforce/apex/DailyReportingController.getPickListValues";

import USER_ID from "@salesforce/user/Id";
import FORM_FACTOR from "@salesforce/client/formFactor";
import fetchApprovals from '@salesforce/apex/DailyReportingController.fetchApprovals'; 

export default class ShowTasksTile extends LightningElement {
  @api outcomeId;
  @api accId;
  @track isEdited = false;
  @track toggleSaveLabel = "Save";
  @track myList = [];
  @track datechangedIdList = 1;
  @track commentsChangedIdList = 1;
  @track dateIdList = [];
  @track commentsIdList = [];

  /*--------------------Mapping field values to the list onchange START --------------------*/

  @track filterContactLookup;
  @track categoryOptions = [];
  @track statusOptions = [];
  @track productOptions = [];
  @track campaignOptions=[];
  @track showSpinner = false;
  @track prodWidthStyle;
  connectedCallback() {
    this.prodWidthStyle = "width:" + parseInt(screen.width / 6) + "px;";
    //task category
    getPickListValues({ key: "In Field" })
      .then((result) => {
        result.forEach((element) =>
          this.categoryOptions.push({ label: element, value: element })
        );
      })
      .catch((error) => {
        this.error = error;
        console.log(this.error);
      });
    //taskstatus
    getPickList({ objectName: "Task", fieldName: "Status" })
      .then((result) => {
        result.forEach((element) =>
          this.statusOptions.push({ label: element, value: element })
        );
        console.log(this.options);
      })
      .catch((error) => {
        this.error = error;
        console.log(this.error);
      });
    //task products
    getPickList({ objectName: "Task", fieldName: "Product__c" })
      .then((result) => {
        result.forEach((element) =>
          this.productOptions.push({ label: element, value: element })
        );
        console.log(this.options);
      })
      .catch((error) => {
        this.error = error;
        console.log(this.error);
      });

      


    this.filterContactLookup = "accountid = '" + this.accId + "'";
    this.getTaskRecords();
  }

  @api getTaskRecords() {
    showTaskList({ outcomeId: this.outcomeId })
      .then((result) => {
        this.myList = result;
        console.log("result");
        console.log(this.myList);
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
          .querySelector('[data-id="myListTable"]')
          .classList.add("formFactorSmall");
      } else if (FORM_FACTOR == "Large") {
        this.template
          .querySelector('[data-id="myTable"]')
          .classList.add(".slds-max-medium-table--stacked");
      }
    }, 300);
  }
  handleDateChange(event) {
    let element = this.myList.find((ele) => ele.Id === event.target.dataset.id);
    let tempList = JSON.parse(JSON.stringify(this.myList));
    tempList.map((e) => {
      if (e.Id === event.target.dataset.id) {
        e.StartDateTime__c = event.target.value;
      }
    });
    this.myList = tempList;

    this.datechangedIdList++;
    this.dateIdList.push(event.target.dataset.id);

    let allOutcomes = this.template.querySelectorAll(".slds-hide");
    const selectedRowId = event.target.dataset.id;
    for (var i = 0; i < allOutcomes.length; i++) {
      let outcomeCells = allOutcomes[i].dataset.id;

      if (outcomeCells == selectedRowId) {
        allOutcomes[i].classList.remove("slds-hide");
        allOutcomes[i].classList.add("slds-show");
        break;
      }
    }
  }
  handleDueDateCommentChange(event) {
    let element = this.myList.find((ele) => ele.Id === event.target.dataset.id);
    let tempList = JSON.parse(JSON.stringify(this.myList));
    tempList.map((e) => {
      if (e.Id === event.target.dataset.id) {
        e.Due_Date_Comments__c = event.target.value;
        e.IsReminderSet = false;
        e.ReminderDateTime = null;
      }
    });
    this.myList = tempList;
    this.commentsChangedIdList++;

    this.commentsIdList.push(event.target.dataset.id);
  }
  handleSubjectChange(event) {
    let element = this.myList.find((ele) => ele.Id === event.target.dataset.id);
    let tempList = JSON.parse(JSON.stringify(this.myList));
    tempList.map((e) => {
      if (e.Id === event.target.dataset.id) {
        e.Subject = event.target.value;
      }
    });
    this.myList = tempList;
    //element.Subject = event.target.value;
    //this.myList = [...this.myList];
  }
  handleCommentChange(event) {
    let element = this.myList.find((ele) => ele.Id === event.target.dataset.id);
    let tempList = JSON.parse(JSON.stringify(this.myList));
    tempList.map((e) => {
      if (e.Id === event.target.dataset.id) {
        e.Comments__c = event.target.value;
      }
    });
    this.myList = tempList;
    //element.Subject = event.target.value;
    //this.myList = [...this.myList];
  }
  handleStatusChange(event) {
    let eventData = event.detail;
    let pickValue = event.detail.selectedValue;
    let uniqueKey = event.detail.key;
    let element = this.myList.find((ele) => ele.Id === uniqueKey);
    let tempList = JSON.parse(JSON.stringify(this.myList));
    tempList.map((e) => {
      if (e.Id === uniqueKey) {
        e.Status = pickValue;
      }
    });
    this.myList = tempList;
  }
  handleProductChange(event) {
    let eventData = event.detail;
    let pickValue = event.detail.selectedValue;
    let uniqueKey = event.detail.key;
    let element = this.myList.find((ele) => ele.Id === uniqueKey);
    let tempList = JSON.parse(JSON.stringify(this.myList));
    tempList.map((e) => {
      if (e.Id === uniqueKey) {
        e.Product__c = pickValue;
      }
    });
    this.myList = tempList;
  }
  handlePriorityChange(event) {
    let eventData = event.detail;
    let pickValue = event.detail.selectedValue;
    let uniqueKey = event.detail.key;

    let element = this.myList.find((ele) => ele.Id === uniqueKey);
    let tempList = JSON.parse(JSON.stringify(this.myList));
    tempList.map((e) => {
      if (e.Id === uniqueKey) {
        e.Priority = pickValue;
      }
    });
    this.myList = tempList;
  }
  handleCategoryChange(event) {
    let eventData = event.detail;
    let pickValue = event.detail.selectedValue;
    let uniqueKey = event.detail.key;
    let element = this.myList.find((ele) => ele.Id === uniqueKey);
    let tempList = JSON.parse(JSON.stringify(this.myList));
    tempList.map((e) => {
      if (e.Id === uniqueKey) {
        e.Category__c = pickValue;
      }
    });
    this.myList = tempList;
  }
  handleTaskCategoryChange(event) {
    let eventData = event.detail;
    let pickValue = event.detail.selectedValue;
    let uniqueKey = event.detail.key;

    let element = this.myList.find((ele) => ele.Id === uniqueKey);
    let tempList = JSON.parse(JSON.stringify(this.myList));
    tempList.map((e) => {
      if (e.Id === uniqueKey) {
        e.Category_Of_Task__c = pickValue;
      }
    });
    this.myList = tempList;
  }

  handleSelection(event) {
    let eventData = event.detail;
    let id = event.detail.selectedId;
    let uniqueKey = event.detail.key;

    let element = this.myList.find((ele) => ele.Id === uniqueKey);
    element.JobType__c = id;
    this.myList = [...this.myList];
  }
  /*--------------------Mapping field values to the list onchange END --------------------*/
  @track isModalOpen = false;
  
  openModal() {
    const todayDate = new Date();
    fetchApprovals({
      userId:USER_ID,
      dateVal:todayDate,
      checkDay:true
  })
  .then(result => {
      console.log(result);
      if(!result) {
          this.isLocked = true;
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Error",
              message: "TASK CREATION IS LOCKED FOR THIS PERIOD. Please raise approval request.",
              variant: "error"
            })
          );
          console.log('In true');
      }
      else {
          this.isLocked = false;
          this.isModalOpen = true;
          console.log('In false');
      }
      })
    .catch(error => {
        console.log(error);
    })  

 
  }
  closeModal() {
    this.isModalOpen = false;    
    //mkt change-3
   // this.isMarketing=false;
    this.campaignName=null;
    this.activityStartDate=null;
  }
  submitDetails() {
    this.isModalOpen = false;
  }
  @track newReminderValue;

  @track reminderRecordId;
  @track isReminderOpen = false;
  handleReminderChange(event) {
    this.newReminderValue = event.target.value;
  }
  openReminderModal(event) {
    let tempList = JSON.parse(JSON.stringify(this.myList));
    console.log("temp");
    console.log(tempList);
    let element = this.myList.find(
      (ele) => ele.Id === event.currentTarget.dataset.id
    );
    console.log("element" + element);

    // let element = templist.find(ele  => ele.Id === event.currentTarget.dataset.id);
    // console.log('element'+element);

    console.log("status" + element.Status);
    if (element.Status === "Completed") {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error",
          message: "Task is Complete. Cannot set Reminder !",
          variant: "error"
        })
      );
    } else {
      this.isReminderOpen = true;
      if (event.currentTarget.dataset.item != undefined) {
        this.newReminderValue = event.currentTarget.dataset.item;
      }
      this.reminderRecordId = event.currentTarget.dataset.id;
      this.isReminderOpen = true;
    }
  }
  closeReminderModal() {
    this.isReminderOpen = false;
    this.newReminderValue = null;
    this.reminderRecordId = null;
  }
  insertReminder() {
    console.log("in reminder");
    setReminder({
      taskId: this.reminderRecordId,
      taskTime: this.newReminderValue
    })
      .then(() => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message: `Reminder Set`,
            variant: "success"
          })
        );
        this.newReminderValue = null;
        this.getTaskRecords();
        this.error = undefined;
      })
      .catch((error) => {
        this.error = error;
        console.log("not set reminder" + this.error);
      });
    console.log("set reminder");
    this.isReminderOpen = false;
  }

  //Add New Task Change Fields------------------------
  @track subject;
  @track activityDate;
  @track activityStartDate;
  @track priority;
  get priorityOptions() {
    return [
      { label: "Low", value: "Low" },
      { label: "Normal", value: "Normal" },
      { label: "High", value: "High" }
    ];
  }

  @track status;
  @track category;
  @track product;
  @track addtaskCategory1;
  get taskCategoryOptions() {
    return [
      { label: "--None--", value: "" },
      { label: "Meeting with Doctor", value: "Meeting with Doctor" },
      { label: "Call with Doctor", value: "Call with Doctor" },
      { label: "Email Doctor", value: "Email Doctor" },
      {
        label: "Meeting with Hospital Head",
        value: "Meeting with Hospital Head"
      },
      { label: "Visit to Hospital", value: "Visit to Hospital" }
    ];
  }

  @track comments;
  subChange(event) {
    this.subject = event.target.value;
  }
  dateChange(event) {
    this.activityStartDate = event.target.value;
    //Mkt change-2
    /*if(this.category=='Marketing Activity'){

      fetchCampaign({selectedDate:this.activityStartDate})
      .then(result => {
          console.log(result);
          this.campaignOptions=[];
          result.forEach(element => 
              this.campaignOptions.push({label: element.Name, value: element.Id })
              );
             // console.log('campaignOptions::'+Json.stringify(this.campaignOptions));
      })
      .catch(error => {
          this.error = error;
          console.log(this.error);
      })  
      this.selectDateErrmsg=false;
      this.isMarketing=true; 
    }  */
    this.checkApproval();
  }
  @track errorReqMessage='TASK CREATION IS LOCKED FOR THIS PERIOD. Please raise approval request.';
  @track isLocked=false;
  checkApproval() {
    const todayDate = new Date();
    const selectedDate = new Date(this.activityStartDate);
    console.log('selected:'+selectedDate)
    const diffTime = selectedDate - todayDate;
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24)); 
    //console.log(diffTime + " milliseconds");
    console.log(diffDays + " days");
    //2 to be replaced by label
    if(diffDays<1) {
      this.errorReqMessage='TASK CREATION IS LOCKED FOR THIS PERIOD. Please raise approval request.';
        // check if approval is present
        //if yes do nothing
        //console.log('In check approval:::');
        fetchApprovals({
            userId:USER_ID,
            dateVal:selectedDate,
            checkDay:false
        })
        .then(result => {
            console.log(result);
            if(!result) {
                this.isLocked = true;
                console.log('In true');
            }
            else {
                this.isLocked = false;
                console.log('In false');
            }
        }
        )
        .catch(error => {
            console.log(error);
        }) 
    }else if(diffDays>7) {
      const day1 = new Date();
      const days=13-day1.getDay();
      if(diffDays>days){        
        this.isLocked = true;
        this.errorReqMessage='Cannot select future date';
      } else{        
          this.isLocked = false;
          this.errorReqMessage='TASK CREATION IS LOCKED FOR THIS PERIOD. Please raise approval request.';
      }
    }
    else {
      console.log('In else:::');
        this.isLocked =false;
    }
}

  @track campaignName;
  addCampaignChange(event){
    this.campaignName=event.detail.value;
  }
  
  commentsChange(event) {
    this.comments = event.target.value;
  }
  addPriorityChange(event) {
    this.priority = event.detail.value;
  }
  
  addStatusChange(event) {
    this.status = event.detail.value;
  }
  addProductChange(event) {
    this.product = event.detail.value;
  }
  @track isMarketing=false;
  @track selectDateErrmsg=false;
  addCategoryChange(event) {
    this.category = event.detail.value;
     //MKT change-1
    /*if(this.category=='Marketing Activity'){
      console.log('this.activityStartDate:'+this.activityStartDate);
      if(this.activityStartDate!=undefined && this.activityStartDate!=null){
      fetchCampaign({selectedDate:this.activityStartDate})
      .then(result => {
          console.log(result);
          this.campaignOptions=[];
          result.forEach(element => 
              this.campaignOptions.push({label: element.Name, value: element.Id })
              );
             // console.log('campaignOptions::'+Json.stringify(this.campaignOptions));
      })
      .catch(error => {
          this.error = error;
          console.log(this.error);
      }) 
      this.isMarketing=true;
      this.selectDateErrmsg=false;
    }else{
      this.selectDateErrmsg=true;
    }

    }else{
      this.isMarketing=false;
      this.campaignName=null;      
      this.selectDateErrmsg=false;
    }*/
  }
  addTaskCategory1(event) {
    this.addtaskCategory1 = event.detail.value;
  }
  @track taskcategorySelection;
  addTaskCategorySelection(event) {
    this.taskcategorySelection = event.detail.selectedValue;
  }
  @track addContact;
  addContactSelection(event) {
    this.addContact = event.detail.selectedValue;
  }
  @track addSupport;
  addSupportSelection(event) {
    this.addSupport = event.detail.selectedValue;
  }

  handleAddProductPicklist(event) {
    event.stopPropagation();
    const detail = event.detail.selectedListData;
    const key = event.detail.key;
    let productPicklistVal = "";
    if (detail.length > 0) {
      productPicklistVal = detail.join(";");
      this.product = productPicklistVal;
    }
    if (detail.length === 0) {
      this.product = "";
    }
  }

  @track newTask;
  handleinsert(event) {
    this.showSpinner=true;
    if (this.category == "" || this.category == null) {
      let comp = this.template.querySelector(".categoryValidation");
      comp.setCustomValidity("Complete this field.");
      comp.reportValidity();
      this.showSpinner=false;
    } else {
      let taskSave = { sobjectType: "Task" };
      taskSave.Subject = "Task";
      taskSave.StartDateTime__c = this.activityStartDate;
      taskSave.Status = this.status;
      taskSave.Product2__c = this.product;
      taskSave.Contact__c = this.addContact;
      taskSave.Support__c = this.addSupport;
      taskSave.Outcome__c = this.outcomeId;
      taskSave.Category__c = this.category;
      taskSave.Comments__c = this.comments;
      //mkt change
      //taskSave.Marketing_Activity__c=this.campaignName;
      taskSave.Task_Type__c = "In Field";
      taskSave.Manager_Approval_Status__c="Pending";

      insertTask({ newTask: taskSave })
        .then((result) => {
          console.log("inserted");
          this.showTasks = false;

          this.activityDate = null;
          this.taskcategorySelection = null;
          this.status = null;
          this.product = null;
          this.addContact = null;
          this.category = null;          
          this.campaignName=null;
          this.comments = null;
          this.taskSave = null;
          this.priority = null;
          this.addSupport = null;

          this.isModalOpen = false;
          this.isMarketing=false;
          this.showSpinner=false;
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Success",
              message: "Tasks inserted",
              variant: "success"
            })
          );
          this.getTaskRecords();
        })
        .catch((error) => {
          console.log(error);
          this.showSpinner=false;
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

  remove(event) {
    //let indexPosition = event.currentTarget.name;
    const recId = event.currentTarget.dataset.id;

    deleteTask({ toDeleteId: recId })
      .then(() => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message: `Record deleted succesfully!`,
            variant: "success"
          })
        );

        this.getTaskRecords();
        this.error = undefined;
      })
      .catch((error) => {
        this.error = error;
      });
  }

  handleSave() {
    this.toggleSaveLabel = "Saving...";

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
        this.myList.some(
          (task) =>
            task.Id === dateCount[i] &&
            task.Due_Date_Comments__c != undefined &&
            (task.Due_Date_Comments__c.trim() === "" ||
              task.Due_Date_Comments__c === null)
        )
      ) {
        commentCount = commentCount.filter((item) => item !== dateCount[i]);
      }
    }

    if (commentCount.length == dateCount.length) {
      let toSaveList = this.myList;
      toSaveList.forEach((element, index) => {
        if (element.Subject === "") {
          toSaveList.splice(index, 1);
        }
      });

      this.myList = toSaveList;
      console.log("save LWC");
      saveTaskLwc({ records: this.myList })
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

          //this.isEdited = false;
          this.getTaskRecords();
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

  onDoubleClickEdit() {
    this.isEdited = true;
  }

  handleCancel() {
    console.log("cancel");
    this.isEdited = false;
    console.log(this.isEdited);
    this.toggleSaveLabel = "Save";

    this.dateIdList = [];
    this.commentsIdList = [];
    

    this.getTaskRecords();
  }

  @track ownerIdselection;
  handleUserSelection(event) {
    this.ownerIdselection = event.detail.selectedValue;
    let uniqueKey = event.detail.key;
    let element = this.myList.find((ele) => ele.Id === uniqueKey);
    let tempList = JSON.parse(JSON.stringify(this.myList));
    tempList.map((e) => {
      if (e.Id === uniqueKey) {
        e.OwnerId = this.ownerIdselection;
      }
    });
    this.myList = tempList;
  }
  @track supportIdselection;
  handleSupportSelection(event) {
    this.supportIdselection = event.detail.selectedValue;
    let uniqueKey = event.detail.key;
    let element = this.myList.find((ele) => ele.Id === uniqueKey);
    let tempList = JSON.parse(JSON.stringify(this.myList));
    tempList.map((e) => {
      if (e.Id === uniqueKey) {
        e.Support__c = this.supportIdselection;
      }
    });
    this.myList = tempList;
  }

  @track whoIdselection;
  handleContactSelection(event) {
    this.whoIdselection = event.detail.selectedValue;
    let uniqueKey = event.detail.key;
    let element = this.myList.find((ele) => ele.Id === uniqueKey);
    let tempList = JSON.parse(JSON.stringify(this.myList));
    tempList.map((e) => {
      if (e.Id === uniqueKey) {
        e.Contact__c = this.whoIdselection;
      }
    });
    this.myList = tempList;
  }

  handleProductPicklistChange(event) {
    event.stopPropagation();
    const detail = event.detail.selectedListData;
    const key = event.detail.key;
    let productPicklistVal = "";
    if (detail.length > 0) {
      productPicklistVal = detail.join(";");
      let tempList = JSON.parse(JSON.stringify(this.myList));
      tempList.map((e) => {
        if (e.Id === key) {
          e.Product2__c = productPicklistVal;
        }
      });
      this.myList = tempList;
    }
    if (detail.length === 0) {
      let tempList = JSON.parse(JSON.stringify(this.myList));
      tempList.map((e) => {
        if (e.Id === key) {
          e.Product2__c = "";
        }
      });
      this.myList = tempList;
    }
  }
}