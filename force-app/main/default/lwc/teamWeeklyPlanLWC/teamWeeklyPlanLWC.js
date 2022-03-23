import { LightningElement, track } from "lwc";

import getUserList from "@salesforce/apex/MyTeamDailyTaskController.getUserList";
import fetchRecords from "@salesforce/apex/MyTeamDailyTaskController.fetchWeeklyPlanRecords";
import insertWeeklyTask from "@salesforce/apex/MyTeamWeeklyTaskController.insertWeeklyTask";
import taskWeeklyApprove from "@salesforce/apex/MyTeamWeeklyTaskController.taskWeeklyApprove";
import fetchManagerId from "@salesforce/apex/MyTeamWeeklyTaskController.fetchManagerId";
import setPriority from "@salesforce/apex/MyTeamWeeklyTaskController.setPriority";

import taskWeeklyReject from "@salesforce/apex/MyTeamWeeklyTaskController.taskWeeklyReject";
import Id from "@salesforce/user/Id";

import { ShowToastEvent } from "lightning/platformShowToastEvent";
import saveTaskWeeklyLwc from "@salesforce/apex/MyTeamWeeklyTaskController.saveTaskWeeklyLwc";
import getPickListValues from "@salesforce/apex/DailyReportingController.getPickListValues";
import getPickList from "@salesforce/apex/DailyReportingController.getPickList"; 


import insertApprovalRequest from '@salesforce/apex/DailyReportingController.insertApprovalRequest';
import fetchApprovals from '@salesforce/apex/DailyReportingController.fetchApprovals';
import USER_ID from '@salesforce/user/Id';

export default class TeamWeeklyPlanLWC extends LightningElement {
  @track defaultDateTo = new Date().toISOString().split("T")[0];
  @track defaultDateFrom = new Date().toISOString().split("T")[0];
  @track defaultDateApproval = new Date().toISOString().split('T')[0];
  @track selectedFromDate = this.defaultDateFrom;
  @track selectedToDate = this.defaultDateTo;
  @track teamUser = [{ label: "--None--", value: "" }];
  @track toggleSaveLabel = "Save";
  @track teamValues;
  @track userList = [];
  @track selectedUserId;
  @track myList = [];
  @track approvalOptions = [];
  @track showSpinner = false;
  @track prodWidthStyle;
  @track weekstart;
  @track weekend;
  @track selectedDistMeet = false;
  @track allTaskCount = { Pending: 0, Approved: 0, Rejected: 0, marketingActivity:0 };
  @track categoryOptions = [];
  @track statusOptions = [];
  @track filterAccountLookup = "recordType.Name='Distributor'";
  @track loggedinUser=Id;
  @track isManagerLogged=false;
  @track showSpinner=false;
  @track isEdited = false;
  onDoubleClickEdit() {
    if(this.isManagerLogged==true){
        
    this.isEdited = true;
    }
  }
  connectedCallback() {
    this.prodWidthStyle = "width:" + parseInt(screen.width / 6) + "px;";

    getUserList()
      .then((result) => {
        console.log("result" + JSON.parse(JSON.stringify(result)));
        //this.userList = result;
        for (let i = 0; i < result.length; i++) {
          // teamUser.push({label:userList[i].Name,value:userList[i].Id});
          console.log("name: " + result[i].Name);
          console.log("id: " + result[i].Id);
          this.teamUser = [
            ...this.teamUser,
            { label: result[i].Name, value: result[i].Id }
          ];
        }
        console.log("picklist user" + this.teamUser);
      })
      .catch((error) => {
        this.error = error;
        this.record = undefined;
      });

    getPickListValues({ key: "Out Field" })
      .then((result) => {
        result.forEach((element) => {
          if (
            element == "Distributor Meeting" ||
            element == "HO Meeting" ||
            element == "Others"
          ) {
            this.categoryOptions.push({ label: element, value: element });
          }
        });
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
  }

  @track isModalOpenApproval;
  showApprovalTable(event){
    this.isModalOpenApproval=true;
  }
  closeModalApproval() {
    this.isModalOpenApproval = false;
  }
  @track approvalStart;
  startDateChange(event){
    this.approvalStart=event.target.value;
  }
  @track approvalEnd;
  endDateChange(event){
    this.approvalEnd=event.target.value;
  }
  handleApprovalinsert(event){

    if(this.approvalStart==null || this.approvalEnd==null){
        if(this.approvalStart==null){
            this.dispatchEvent(
                new ShowToastEvent({
                    title : 'Error',
                    message : 'Select Start Date',
                    variant : 'error',
                }),
            );
        } else if(this.approvalEnd==null){
            this.dispatchEvent(
                new ShowToastEvent({
                    title : 'Error',
                    message : 'Select End Date',
                    variant : 'error',
                }),
            );
        } 
    }else{ 
    insertApprovalRequest({
        startDate:this.approvalStart,
        endDate:this.approvalEnd
      })
      .then(()=>{
        this.approvalStart=null;
        this.approvalEnd=null;
        this.dispatchEvent(
            new ShowToastEvent({
                title : 'Success',
                message : 'Approval Sent!',
                variant : 'success',
            }),
        );
        //this.isLocked = false;
        this.activityStartDate = this.defaultDateApproval;
        this.isModalOpenApproval = false;
      }) 
    }

  }







  handleFromDateChange(event) {
    this.selectedFromDate = event.target.value;
  }
  handleToDateChange(event) {
    this.selectedToDate = event.target.value;
  }
  handleUserChange(event) {
    console.log("user val: " + event.target.value);
    this.selectedUserId = event.target.value;
  }
  showTask(event) {
    this.allTaskCount = { Pending: 0, Approved: 0, Rejected: 0 ,marketingActivity:0};
    this.showSpinner = true;

    fetchRecords({
      userId: this.selectedUserId,
      fromDate: this.selectedFromDate,
      toDate: this.selectedToDate
    })
      .then((result) => {
        console.log("Task result: " + result);
        
        

        this.myList = result;
        if(this.myList.length>0){
          fetchManagerId({ userId: this.selectedUserId })
          .then((result) => {
            console.log("Task Manager result: " + result);
            if(this.loggedinUser==result){
              this.isManagerLogged=true;
              console.log("Task Manager result: " + true);
            }else if(this.isManagerLogged==true){
              this.isManagerLogged=false;
              console.log("Task Manager result: " + false);
            }
          })    
        }
          
        this.showSpinner = false;
        this.myList.forEach((element) => {
          if (element.Product2__c) {
            element.Product2__c = element.Product2__c.replaceAll(";", ",");
          }
          if(element.Category__c == "Marketing Activity") {
            this.allTaskCount.marketingActivity += 1;
          }
          if (element.Manager_Approval_Status__c == "Pending") {
            this.allTaskCount.Pending += 1;
          } else if (element.Manager_Approval_Status__c == "Approved") {
            this.allTaskCount.Approved += 1;
          } else if (element.Manager_Approval_Status__c == "Rejected") {
            this.allTaskCount.Rejected += 1;
          }

        });
        if (this.isEdited == true) {
          this.isEdited = false;
        }
      })
      .catch((error) => {
        this.error = error;
        this.record = undefined;
        console.log("err " + this.error);
        this.showSpinner = false;
      });
  }
  //Modal Activities
  @track addDist;
  addDistributorSelection(event) {
    this.addDist = event.detail.selectedValue;
  }
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
    this.isLocked = false;
  }
  submitDetails() {
    this.isModalOpen = false;
  }
  @track category;
  addCategoryChange(event) {
    this.category = event.detail.value;
    if (this.category == "Distributor Meeting") {
      this.selectedDistMeet = true;
    } else {
      this.selectedDistMeet = false;
      this.addDist = null;
    }
  }
  @track activityStartDate;
  dateChange(event) {
    this.activityStartDate = event.target.value;
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

  @track status;
  addStatusChange(event) {
    this.status = event.detail.value;
  }
  @track comments;
  commentsChange(event) {
    this.comments = event.target.value;
  }
  @track product;
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
  @track selectedAccount;
  handleAccountSelection(event) {
    this.selectedAccount = event.detail;
  }
  @track approveIdList = [];
  handleCheckboxChange(event) {
    let element = this.myList.find((ele) => ele.Id === event.target.dataset.id);
    console.log("checked:" + element.Id);

    if (event.target.checked == true) {
      console.log("checked:true");
      let taskSave = { sobjectType: "Task" };
      taskSave.Id = element.Id;
      taskSave.Manager_Comments__c = element.Manager_Comments__c;
      let flag = false;
      this.approveIdList.forEach((element) => {
        if (element.Id == event.target.dataset.id) {
          this.approveIdList.splice(counter, 1, taskSave);
          flag = true;
        }
      });
      if (!flag) {
        this.approveIdList.push(taskSave);
      }
    } else if (event.target.checked == false) {
      let counter = 0;
      this.approveIdList.forEach((element) => {
        if (element.Id == event.target.dataset.id) {
          this.approveIdList.splice(counter, 1);
        }
        counter++;
      });
    }

    console.log("checked List:");
    console.log(this.approveIdList);
  }
  //save multi rejected tasks
  handleRejectManager(event) {
    console.log("approve LWC" + this.approveIdList);

    taskWeeklyReject({ records: this.approveIdList })
      .then(() => {
        this.toggleSaveLabel = "Saved";

        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message: `Records saved succesfully!`,
            variant: "success"
          })
        );
        this.myList = [];
        this.approveIdList = [];
        this.showTask();
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

  //save multi approved tasks
  handleApproveManager(event) {
    console.log("approve LWC");

    taskWeeklyApprove({ records: this.approveIdList })
      .then(() => {
        this.toggleSaveLabel = "Saved";

        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message: `Records saved succesfully!`,
            variant: "success"
          })
        );
        this.myList = [];
        this.approveIdList = [];
        this.showTask();
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

  handleApprovalStatusChange(event) {
    event.currentTarget.parentElement.parentElement.style.backgroundColor =
      "LAVENDER";
    let eventData = event.detail;
    let pickValue = event.detail.selectedValue;
    let uniqueKey = event.detail.key;
    let element = this.myList.find((ele) => ele.Id === uniqueKey);
    let tempList = JSON.parse(JSON.stringify(this.myList));
    tempList.map((e) => {
      if (e.Id === uniqueKey) {
        e.Manager_Approval_Status__c = pickValue;
      }
    });
    this.myList = tempList;
  }
  handleManagerCommentChange(event) {
    event.currentTarget.parentElement.parentElement.style.backgroundColor =
      "LAVENDER";
    let element = this.myList.find((ele) => ele.Id === event.target.dataset.id);
    let tempList = JSON.parse(JSON.stringify(this.myList));
    tempList.map((e) => {
      if (e.Id === event.target.dataset.id) {
        e.Manager_Comments__c = event.target.value;
      }
    });
    this.myList = tempList;
    //element.Subject = event.target.value;
    //this.myList = [...this.myList];
  }
  handleCancelManager() {
    console.log("cancel");
    this.isEdited = false;
    console.log(this.isEdited);
    this.toggleSaveLabel = "Save";
    this.myList = [];
    this.showTask();
  }

  handleinsert(event) {
    if (this.category == "" || this.category == null) {
      let comp = this.template.querySelector(".categoryValidation");
      comp.setCustomValidity("Complete this field.");
      comp.reportValidity();
    } else {
      this.showSpinner=true;

      let taskSave = { sobjectType: "Task" };
      taskSave.Subject = "Task";
      taskSave.StartDateTime__c = this.activityStartDate;
      taskSave.Status = this.status;
      taskSave.WhatId = this.addDist;
      taskSave.Product2__c = this.product;
      taskSave.Category__c = this.category;
      taskSave.Comments__c = this.comments;
      taskSave.Task_Type__c = "Out Field";
      taskSave.Manager_Approval_Status__c="Pending";
      
      insertWeeklyTask({ newTask: taskSave })
        .then((result) => {
          console.log("inserted");
          this.addDist = null;
          this.showTasks = false;
          this.selectedDistMeet = false;
          this.activityStartDate = null;
          this.status = null;
          this.product = null;
          this.category = null;
          this.comments = null;
          this.taskSave = null;

          this.isModalOpen = false;
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Success",
              message: "Tasks inserted",
              variant: "success"
            })
          );
          this.showSpinner=false;
          this.showTask();
        })
        .catch((error) => {
          console.log(error);
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Error saving record",
              message: error.body.message,
              variant: "error"
            })
          );
          this.showSpinner=false;
        });
    }
  }

  handleSaveManager() {
    this.toggleSaveLabel = "Saving...";

    console.log("save LWC");
    saveTaskWeeklyLwc({ records: this.myList })
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
        this.myList = [];
        this.showTask();
        console.log("after get rec");

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
  @track priorityLst =[];
  @track priorityBtnLabel = "Update Activity Priority";
  @track isPriorityBtnClicked = false;
  showPriorityCheckBox() {
    this.priorityLst = [];
    this.isPriorityBtnClicked = !this.isPriorityBtnClicked;
    // if(this.isPriorityBtnClicked) {
    //   //this.priorityBtnLabel = "Update Priority";
    // }
    // else {
    //   this.handlePriorityUpdate();
    //   //this.priorityBtnLabel = "Update Activity Priority";
    // }
  }
  setPriorityToHigh() {
    this.isPriorityBtnClicked = !this.isPriorityBtnClicked;
    this.priorityLst.forEach((element) => {
     element.Priority = "High";
      });
      this.handlePriorityUpdate();
  }
  setPriorityToNormal() {
    this.isPriorityBtnClicked = !this.isPriorityBtnClicked;
    this.priorityLst.forEach((element) => {
      element.Priority = "Normal";
       });
       this.handlePriorityUpdate();
  }
  cancelPriorityUpdate() {
    //this.isPriorityBtnClicked = !this.isPriorityBtnClicked;
    this.showPriorityCheckBox();
  }
  handlepriorityBtn(event) {
    let element = this.myList.find((ele) => ele.Id === event.target.dataset.id);
    console.log("checked:" + element.Id);

    if (event.target.checked == true) {
      console.log("checked:true");
      let taskSave = { sobjectType: "Task" };
      taskSave.Id = element.Id;
      //taskSave.Priority = 'High';
      let flag = false;
      this.priorityLst.forEach((element) => {
        if (element.Id == event.target.dataset.id) {
          this.priorityLst.splice(counter, 1, taskSave);
          flag = true;
        }
      });
      if (!flag) {
        this.priorityLst.push(taskSave);
      }
    } else if (event.target.checked == false) {
      let counter = 0;
      this.priorityLst.forEach((element) => {
        if (element.Id == event.target.dataset.id) {
          this.priorityLst.splice(counter, 1);
        }
        counter++;
      });
    }

    console.log("checked List:");
    console.log(this.priorityLst);
  }
  handlePriorityUpdate() {
    this.showSpinner = true;
    console.log("save LWC this.priorityLst");
    console.log(this.priorityLst)
    setPriority({ records: this.priorityLst })
      .then(() => {

        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message: `Records saved succesfully!`,
            variant: "success"
          })
        );

        //this.isEdited = false;
        this.myList = [];
        this.showTask();

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
      });
      
  }
  showPriorityTasks() {
    
  }
}