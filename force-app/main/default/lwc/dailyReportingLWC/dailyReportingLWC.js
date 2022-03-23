import { LightningElement, track } from 'lwc';
import USER_ID from '@salesforce/user/Id';
import fetchRecords from '@salesforce/apex/DailyReportingController.fetchRecords';
import insertTaskList from '@salesforce/apex/DailyReportingController.insertTaskList';
import insertApprovalRequest from '@salesforce/apex/DailyReportingController.insertApprovalRequest';
import fetchAllDailyTask from '@salesforce/apex/MyTeamDailyTaskController.fetchAllDailyTask';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getPickListValues from '@salesforce/apex/DailyReportingController.getPickListValues';
import fetchTask from '@salesforce/apex/MyTeamDailyTaskController.fetchRecords';
import fetchApprovals from '@salesforce/apex/DailyReportingController.fetchApprovals';
import saveTaskLwc from "@salesforce/apex/MilestoneRecordPage.saveTaskLwc";
import getAccDetails from '@salesforce/apex/DailyReportingController.getAccDetails';

export default class DailyReportingLWC extends LightningElement {

    @track selectedAccount;
    @track accountFilter = "ownerid = '" + USER_ID + "'";
    @track defaultDate = new Date().toISOString().split('T')[0];
    @track dateVal = this.defaultDate;
    @track myList = [];
    @track showTable = false;
    @track showSpinner = false;
    @track toggleSaveLabel = "Save";
    @track nfValue;
    @track nfOptions = [];
    @track nAddInFields = [];// ---
    @track nfdetail;
    @track isModalOpen = false;

    @track leaveValue;
    @track leaveOptions = [];
    @track leavedetail;
    @track allTaskList = [];
    @track allTaskCount = { completed: 0, inProgress: 0, notStarted: 0 };
    @track prodWidthStyle;

    //---
    @track dailyTasks = [];
    @track dailyTaskList = [];


    @track filterContactLookup;
    @track filterAccountLookup;
    accId;
    @track dateIdList = [];
    @track commentsIdList = [];

    @track isLocked = false;
    @track counter = 0;
    @track isEdited = false;
    errorFlag = false;
    @track statusforDate;
    @track disableButton = false;

    get options() {
        return [
            { label: 'High', value: 'High' },
            { label: 'Normal', value: 'Normal' },
            { label: 'Low', value: 'Low' },
        ];
    }



    connectedCallback() {
        console.log('default date ' + this.defaultDate)
        this.prodWidthStyle = "width:" + parseInt(screen.width / 6) + "px;";
        getPickListValues({ key: 'Leave' })
            .then(result => {
                console.log(result);
                result.forEach(element =>
                    this.leaveOptions.push({ label: element, value: element })
                );
            }
            )
            .catch(error => {
                this.error = error;
                console.log(this.error);
            })
        getPickListValues({ key: 'Out Field' })
            .then(result => {
                console.log(result);
                result.forEach(element =>
                    this.nfOptions.push({ label: element, value: element })
                );
                console.log('nfOptions' + this.nfOptions);
            }
            )
            .catch(error => {
                this.error = error;
                console.log(this.error);
            })
        //--
        getPickListValues({ key: 'In Field' })
            .then(result => {
                console.log(result);
                result.forEach(element =>
                    this.nAddInFields.push({ label: element, value: element })

                );
                console.log('naddinfields' + this.nAddInFields);
            }
            )
            .catch(error => {
                this.error = error;
                console.log(this.error);
            })
        //--
        this.showTask();
        this.showDailyTasks();
        //  showPlannedTask();
    }

    leaveTypeHandleChange(event) {
        console.log(event.target.value);
        this.leaveValue = event.target.value;
    }
    nfHandleChange(event) {
        console.log(event.target.value);
        this.nfValue = event.target.value;
    }
    handleNonFieldDetaisChange(event) {
        console.log(event.target.value);
        this.nfdetail = event.target.value;
    }
    handleLeaveDetaisChange(event) {
        console.log(event.target.value);
        this.leavedetail = event.target.value;
    }
    handleAccountSelection(event) {
        this.selectedAccount = event.detail;
    }
    handleDateChange(event) {

        this.dateVal = event.target.value;
        console.log('this.dateVal' + this.dateVal);
        console.log('this.default' + this.defaultDate);
        if (this.dateVal > this.defaultDate) {
            this.disableButton = true;
        } else {
            this.disableButton = false;
        }
        console.log('disablebuuton' + this.disableButton);
        this.checkApproval();
        this.showTask();
        //-----
        this.showDailyTasks();
    }
    @track errorMsgAppr = 'TASK CREATION IS LOCKED FOR THIS PERIOD. Please click below button to raise request';
    checkApproval() {
        const todayDate = new Date();
        const selectedDate = new Date(this.dateVal);
        const diffTime = selectedDate - todayDate;
        const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
        console.log(diffTime + " milliseconds");
        console.log(diffDays + " days");
        //2 to be replaced by label
        if (diffDays < -2) {
            // check if approval is present
            //if yes do nothing
            fetchApprovals({
                userId: USER_ID,
                dateVal: selectedDate,
                checkDay: false
            })
                .then(result => {
                    console.log(result);
                    if (!result) {
                        this.isLocked = true;
                        this.errorMsgAppr = 'TASK CREATION IS LOCKED FOR THIS PERIOD. Please click below button to raise request';
                    }
                    else {
                        this.isLocked = false;
                    }
                }
                )
                .catch(error => {
                    console.log(error);
                })
        } else if (diffDays >= 1) {
            this.isLocked = true;
            fetchApprovals({
                userId: USER_ID,
                dateVal: selectedDate,
                checkDay: false
            })
                .then(result => {
                    console.log(result);
                    if (!result) {
                        this.isLocked = true;
                        this.errorMsgAppr = 'TASK CREATION IS LOCKED FOR FUTURE DATE.';
                    }
                    else {
                        this.isLocked = false;
                        this.errorMsgAppr = 'TASK CREATION IS LOCKED FOR THIS PERIOD. Please click below button to raise request';
                    }
                }
                )
                .catch(error => {
                    console.log(error);
                })

        } else {
            this.isLocked = false;
            this.errorMsgAppr = 'TASK CREATION IS LOCKED FOR THIS PERIOD. Please click below button to raise request';
        }
    }
    showTaskTable() {
        this.showSpinner = true;
        console.log(this.selectedAccount);
        console.log(this.dateVal);
        this.myList = [];
        fetchRecords({ accountId: this.selectedAccount })
            .then(result => {
                console.log(result);
                this.myList = result;
                this.showSpinner = false;
                this.showTable = true;
            })
            .catch(error => {
                console.log(error);
            });
    }
    addLeave() {
        let flag = false;
        console.log('this.leaveValue' + this.leaveValue);
        if (this.leaveValue == '' || this.leaveValue == undefined || this.leavedetail == '' || this.leavedetail == undefined) {
            this.flag = true;
        }
        console.log('flag' + this.flag);
        if (this.flag) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: `Please Enter all Required  Fields`,
                    variant: 'error',
                }),

            );
            this.flag = false;
        } else {
            this.showSpinner = true;
            let taskList = [];
            let newTask = { 'sobjectType': 'Task' };
            newTask.Task_Type__c = 'Leave';
            newTask.Category__c = this.leaveValue;
            newTask.Field_Non_Field__c = false;
            newTask.StartDateTime__c = this.dateVal;
            newTask.Comments__c = this.leavedetail;
            newTask.Status = 'Complete';
            taskList.push(newTask);
            insertTaskList({ taskList: taskList })
                .then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: `Task added succesfully!`,
                            variant: 'success',
                        }),
                    );
                    this.showSpinner = false;
                    this.showTask();
                    this.showTable = false;
                    this.leaveValue = '';
                    this.leavedetail = '';
                }
                )
                .catch(error => {
                    this.error = error;
                    console.log(this.error);
                    this.showSpinner = false;
                })
        }
    }
    addOutField() {
        let flag = false;
        console.log('this.leaveValue' + this.leaveValue);
        if (this.nfValue == '' || this.nfValue == undefined || this.nfdetail == '' || this.nfdetail == undefined) {
            this.flag = true;
        }
        console.log('flag' + this.flag);
        if (this.flag) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: `Please Enter all Required  Fields`,
                    variant: 'error',
                }),

            );
            this.flag = false;
        } else {
            this.showSpinner = true;
            let taskList = [];
            let newTask = { 'sobjectType': 'Task' };
            newTask.Task_Type__c = 'Out Field';
            newTask.Category__c = this.nfValue;
            newTask.Field_Non_Field__c = false;
            newTask.StartDateTime__c = this.dateVal;
            newTask.Status = 'Complete';
            newTask.Comments__c = this.nfdetail;
            taskList.push(newTask);
            insertTaskList({ taskList: taskList })
                .then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: `Task added succesfully!`,
                            variant: 'success',
                        }),
                    );
                    this.showSpinner = false;
                    this.showTask();
                    this.nfValue = '';
                    this.nfdetail = ' ';
                    this.showTable = false;
                }
                )
                .catch(error => {
                    this.error = error;
                    console.log(this.error);
                    this.showSpinner = false;
                })
        }
    }
    showApprovalTable(event) {
        this.isModalOpen = true;
    }
    closeModal() {
        this.isModalOpen = false;
    }

    @track approvalStart;
    startDateChange(event) {
        this.approvalStart = event.target.value;
    }
    @track approvalEnd;
    endDateChange(event) {
        this.approvalEnd = event.target.value;
    }
    handleApprovalinsert(event) {

        if (this.approvalStart == null || this.approvalEnd == null) {
            if (this.approvalStart == null) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Select Start Date',
                        variant: 'error',
                    }),
                );
            } else if (this.approvalEnd == null) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Select End Date',
                        variant: 'error',
                    }),
                );
            }
        } else {
            insertApprovalRequest({
                startDate: this.approvalStart,
                endDate: this.approvalEnd
            })
                .then(() => {
                    this.approvalStart = null;
                    this.approvalEnd = null;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Approval Sent!',
                            variant: 'success',
                        }),
                    );
                    //this.isLocked = false;
                    this.dateVal = this.defaultDate;
                    this.isModalOpen = false;
                })
        }

    }






    //errorF = false;
    submitReport(event) {
        //let errorF=false;
        this.showSpinner = true;
        console.log('list:' + JSON.stringify(this.myList));

        // this.myList.forEach((ele, ind) => {
        //     console.log('ele :' + ele.status);
        //     if (ele.Select == true) {
        //         if ((ele.Status == undefined || ele.Category__c == undefined || ele.Product2__c == undefined || ele.Priority == undefined || ele.Comments__c == undefined)) {
        //             this.errorF = true;
        //             //return;
        //         }
        //     }
        // })



        for (let i = 0; i < this.myList.length; i++) {
            console.log('this.myList[i]::' + JSON.stringify(this.myList[i]));
            if (this.myList[i].Select) {
                if (this.myList[i].Select == true) {
                    if (this.myList[i].Status == undefined || this.myList[i].Category__c == undefined
                        || this.myList[i].Product2__c == undefined || this.myList[i].Priority == undefined
                        || this.myList[i].Comments__c == undefined) {
                        //this.errorF = true;
                        this.showSpinner = false;
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error',
                                message: `Please Enter All Fields!`,
                                variant: 'Error',
                            }),
                        );
                        return;
                    }
                }
            }

        }



        // if (this.errorF) {
        //     this.showSpinner = false;
        //     this.dispatchEvent(
        //         new ShowToastEvent({
        //             title: 'Error',
        //             message: `Please Enter All Fields!`,
        //             variant: 'Error',
        //         }),
        //     );
        // } else {
            let taskList = [];
            let tempList = JSON.parse(JSON.stringify(this.myList));
            console.log('temp list' + tempList);
            console.log('temp list size1:' + tempList.length);
            console.log('bfr for');
            for (let i = 0; i < tempList.length; i++) {

                if (tempList[i].Select) {
                    if (tempList[i].Select == true) {
                        let newTask = { 'sobjectType': 'Task' };
                        console.log('contact id: ' + tempList[i].Id);
                        newTask.WhatId = tempList[i].AccountId;
                        newTask.Account__c = tempList[i].AccountId;
                        newTask.WhoId = tempList[i].Id;
                        newTask.Category__c = tempList[i].Category__c;
                        //newTask.Product__c=tempList[i].Product__c;
                        newTask.Product2__c = tempList[i].Product2__c;
                        newTask.Support__c = tempList[i].Support__c;
                        newTask.Task_Type__c = 'In Field';
                        newTask.Field_Non_Field__c = true;
                        newTask.Comments__c = tempList[i].Comments__c;
                        newTask.Priority = tempList[i].Priority;
                        newTask.StartDateTime__c = this.dateVal;
                        newTask.Status = tempList[i].Status;
                        taskList.push(newTask);

                    }
                }
            }
            if (taskList.length > 0) {
                insertTaskList({ taskList: taskList })
                    .then(() => {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: `Task added succesfully!`,
                                variant: 'success',
                            }),
                        );
                        this.showSpinner = false;
                        this.showTable = false;
                        this.showTask();
                    }
                    )
                    .catch(error => {
                        this.error = error;
                        console.log(this.error);
                        this.showSpinner = false;
                    })
                //this.showTaskTable();
            } else {
                console.log('else select info');
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Cannot Submit',
                        message: 'Please select at least one record',
                        variant: 'info'
                    })
                );
                this.showSpinner = false;
            }
       // }


    }

    //LWC TABLE VALUES HANDLE
    handleCategoryChange(event) {
        let eventData = event.detail;
        let pickValue = event.detail.selectedValue;
        let uniqueKey = event.detail.key;
        let element = this.myList.find(ele => ele.Id === uniqueKey);
        let tempList = JSON.parse(JSON.stringify(this.myList));
        tempList.map(e => {
            if (e.Id === uniqueKey) {
                e.Category__c = pickValue;
            }
        })
        this.myList = tempList;
    }


    handleStatus(event) {
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
    // handleProductChange(event) { 
    //     let eventData = event.detail; 
    //     let pickValue = event.detail.selectedValue; 
    //     let uniqueKey = event.detail.key; 
    //     let element = this.myList.find(ele  => ele.Id === uniqueKey);  
    //     let tempList  = JSON.parse(JSON.stringify(this.myList)); 
    //     tempList.map(e =>{
    //         if(e.Id === uniqueKey){
    //             e.Product__c = pickValue;
    //         }
    //     })  
    //     this.myList = tempList; 
    // }
    handleProductPicklistChange(event) {
        event.stopPropagation();
        const detail = event.detail.selectedListData;
        const key = event.detail.key;
        let productPicklistVal = '';
        if (detail.length > 0) {
            productPicklistVal = detail.join(';');
            let tempList = JSON.parse(JSON.stringify(this.myList));
            tempList.map(e => {
                if (e.Id === key) {
                    e.Product2__c = productPicklistVal;
                }
            })
            this.myList = tempList;
        }
        if (detail.length === 0) {

            let tempList = JSON.parse(JSON.stringify(this.myList));
            tempList.map(e => {
                if (e.Id === key) {
                    e.Product2__c = '';
                }
            })
            this.myList = tempList;
        }
    }

    handleChange(event) {
        this.value = event.detail.value;
        var uniqueKey = event.target.dataset.id;
        let tempList = JSON.parse(JSON.stringify(this.myList));
        tempList.map(e => {
            if (e.uniKey === uniqueKey) {
                e.Priority = this.value;
            }
        })
        this.myList = tempList;
    }

    handleCommentChange(event) {
        let element = this.myList.find(ele => ele.Id === event.target.dataset.id);
        let tempList = JSON.parse(JSON.stringify(this.myList));
        tempList.map(e => {
            if (e.Id === event.target.dataset.id) {
                e.Comments__c = event.target.value;
            }
        })
        this.myList = tempList;
    }

    @track supportIdselection;
    handleSupportSelection(event) {
        this.supportIdselection = event.detail.selectedValue;
        let uniqueKey = event.detail.key;
        let element = this.myList.find(ele => ele.Id === uniqueKey);
        let tempList = JSON.parse(JSON.stringify(this.myList));
        tempList.map(e => {
            if (e.Id === uniqueKey) {
                e.Support__c = this.supportIdselection;
            }
        })
        this.myList = tempList;
    }
    handleSelectChange(event) {
        let element = this.myList.find(ele => ele.Id === event.target.dataset.id);
        let tempList = JSON.parse(JSON.stringify(this.myList));
        if (event.target.checked) {
            tempList.map(e => {
                if (e.Id === event.target.dataset.id) {
                    e.Select = true;
                }
            })
        } else {
            tempList.map(e => {
                if (e.Id === event.target.dataset.id) {
                    e.Select = false;
                }
            })
        }
        this.myList = tempList;
    }
    showTask() {
        this.allTaskCount = { completed: 0, inProgress: 0, notStarted: 0 };
        this.showSpinner = true;
        fetchTask({ userId: USER_ID, taskDate: this.dateVal })
            .then(result => {
                this.showSpinner = false;
                console.log('Task result: ' + result);
                this.allTaskList = result;
                this.allTaskList.forEach(element => {
                    if (element.Product2__c) {
                        element.Product2__c = element.Product2__c.replaceAll(';', ',');
                    }
                    if (element.Status == 'Complete') {
                        this.allTaskCount.completed += 1;
                    }
                    else if (element.Status == 'In Progress') {
                        this.allTaskCount.inProgress += 1;
                    }
                    else if (element.Status == 'Not Started') {
                        this.allTaskCount.notStarted += 1;
                    }
                }
                )


            })
            .catch(error => {
                this.error = error;
                this.record = undefined;
                this.showSpinner = false;
                console.log('err ' + this.error);
            });
    }
    showInFieldTasks() {
        this.template.querySelector('.in-field-section').classList.add("slds-is-open");
        this.template.querySelector('.leave-section').classList.remove("slds-is-open");
        this.template.querySelector('.out-field-section').classList.remove("slds-is-open");
        this.template.querySelector('.planned-task-section').classList.remove("slds-is-open");  //---

    }
    showLeaveSection() {
        this.template.querySelector('.leave-section').classList.add("slds-is-open");
        this.template.querySelector('.out-field-section').classList.remove("slds-is-open");
        this.template.querySelector('.in-field-section').classList.remove("slds-is-open");
        this.template.querySelector('.planned-task-section').classList.remove("slds-is-open"); //---
    }
    showNonFieldTasks() {
        this.template.querySelector('.out-field-section').classList.add("slds-is-open");
        this.template.querySelector('.in-field-section').classList.remove("slds-is-open");
        this.template.querySelector('.leave-section').classList.remove("slds-is-open");
        this.template.querySelector('.planned-task-section').classList.remove("slds-is-open"); //--

    }
    showPlannedTask() {
        this.template.querySelector('.out-field-section').classList.remove("slds-is-open");//   
        this.template.querySelector('.in-field-section').classList.remove("slds-is-open"); //
        this.template.querySelector('.leave-section').classList.remove("slds-is-open");//
        this.template.querySelector('.planned-task-section').classList.add("slds-is-open"); //--
    }

    ///  by varsha
    showDailyTasks() {
        this.showSpinner = true;


        fetchAllDailyTask({ userId: USER_ID, selectedDate: this.dateVal })
            .then(result => {
                this.showSpinner = false;
                console.log('Task result: ' + result);

                this.dailyTasks = result;


                this.dailyTasks.forEach((element) => {
                    if (element.Status == 'Complete') {
                        element.statusforError = true;
                    } else {

                        element.statusforError = false;
                    }
                })

                this.dailyTaskList = this.dailyTasks;

            })
            .catch(error => {
                this.error = error;
                this.record = undefined;
                this.showSpinner = false;
                console.log('err ' + this.error);
            });

    }

    onDoubleClickEdit() {
        this.isEdited = true;
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
                this.dailyTasks.some(
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
            let toSaveList = this.dailyTasks;
            toSaveList.forEach((element, index) => {
                if (element.Subject === "") {
                    toSaveList.splice(index, 1);
                }
            });

            // this.dailyTasks = toSaveList;
            console.log(" this.dailyTasks::" + JSON.stringify(this.dailyTasks));
            this.dailyTasks.forEach((elem, index) => {
                console.log('errorflag' + this.errorFlag);
                //this.statusforDate=elem.Status;
                // console.log('statusforDate'+this.statusforDate);
                if ((elem.Status == 'In Progress' || elem.Status == 'Not Started') && elem.StartDateTime__c < this.dateVal) {
                    this.errorFlag = true;
                    // this.statusforDate=true;
                    console.log(this.errorFlag);
                }
                console.log(this.errorFlag);
                console.log(elem); // the elment
                console.log(index); // the index in the NodeList
            });

            if (this.errorFlag) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error for saving Record",
                        message: `Cannot assign task to a previous date`,
                        variant: "error"
                    })
                );
                this.toggleSaveLabel = "Save";
                this.errorFlag = false;
            } else {
                console.log("save LWC");
                console.log(" this.dailyTasks::" + JSON.stringify(this.dailyTasks));
                saveTaskLwc({ records: this.dailyTasks,account:  null})
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
                        this.showDailyTasks();
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
        showDailyTasks();
    }


    handleCancel() {
        console.log("cancel");
        this.isEdited = false;
        console.log(this.isEdited);
        this.toggleSaveLabel = "Save";

        this.dateIdList = [];
        this.commentsIdList = [];
        this.getTaskDetails();

        //this.getTaskRecords();
    }


    handleStatusChange(event) {
        let eventData = event.detail;
        let pickValue = event.detail.selectedValue;
        let uniqueKey = event.detail.key;
        let element = this.dailyTasks.find((ele) => ele.Id === uniqueKey);
        let tempList = JSON.parse(JSON.stringify(this.dailyTasks));
        tempList.map((e) => {
            if (e.Id === uniqueKey) {
                e.Status = pickValue;
            }
        });
        this.dailyTasks = tempList;
    }

    handlePriorityChange(event) {
        let eventData = event.detail;
        let pickValue = event.detail.selectedValue;
        let uniqueKey = event.detail.key;
        let element = this.dailyTasks.find((ele) => ele.Id === uniqueKey);
        let tempList = JSON.parse(JSON.stringify(this.dailyTasks));
        tempList.map((e) => {
            if (e.Id === uniqueKey) {
                e.Priority = pickValue;
            }
        });
        this.dailyTasks = tempList;
    }
    handleDetailChange(event) {
        let element = this.myList.find(ele => ele.Id === event.target.dataset.id);
        let tempList = JSON.parse(JSON.stringify(this.dailyTasks));
        tempList.map(e => {
            if (e.Id === event.target.dataset.id) {
                e.Comments__c = event.target.value;
            }
        })
        this.dailyTasks = tempList;
    }
    handleTypeChange(event) {
        let eventData = event.detail;
        let pickValue = event.detail.selectedValue;
        let uniqueKey = event.detail.key;
        let element = this.dailyTasks.find((ele) => ele.Id === uniqueKey);
        let tempList = JSON.parse(JSON.stringify(this.dailyTasks));
        tempList.map((e) => {
            if (e.Id === uniqueKey) {
                e.Category__c = pickValue;
                e.Task_Type__c = 'In Field';
            }
        });
        this.dailyTasks = tempList;
    }
    @track whoIdselection;
    handleContactSelection(event) {
        this.whoIdselection = event.detail.selectedValue;
        let uniqueKey = event.detail.key;
        let element = this.dailyTasks.find((ele) => ele.Id === uniqueKey);
        let tempList = JSON.parse(JSON.stringify(this.dailyTasks));
        tempList.map((e) => {
            if (e.Id === uniqueKey) {
                e.Contact__c = this.whoIdselection;
                // this.accId = e.WhatId;
            }
        });
        this.dailyTasks = tempList;
        // this.filterContactLookup = "accountid = '" + this.accId + "'";
        this.filterContactLookup = "accountid = '" + this.selectedAccount + "'";
        console.log(' this.filterContactLookup ' + this.filterContactLookup);

    }

    @track supportIdselection;
    handleSupportSelectionTask(event) {
        this.supportIdselection = event.detail.selectedValue;
        let uniqueKey = event.detail.key;
        let element = this.dailyTasks.find((ele) => ele.Id === uniqueKey);
        let tempList = JSON.parse(JSON.stringify(this.dailyTasks));
        tempList.map((e) => {
            if (e.Id === uniqueKey) {
                e.Support__c = this.supportIdselection;
            }
        });
        this.dailyTasks = tempList;
    }
    // @track accountidselection
    // handleAccountSelectionChange(event){
    //   this.accountidselection = event.detail.selectedValue;
    //     let uniqueKey = event.detail.key;
    //     let element = this.dailyTasks.find((ele) => ele.Id === uniqueKey);
    //     let tempList = JSON.parse(JSON.stringify(this.dailyTasks));
    //     tempList.map((e) => {
    //     if (e.Id === uniqueKey) {
    //         e.Account = this.accountidselection;
    //         this.accId = e.Account__c;
    //     }
    //     });
    //     this.dailyTasks = tempList;
    //     this.filterAccountLookup = "accountid = '" + this.accId + "'";

    // }       

    handleAccountSelection(event) {
        this.selectedAccount = event.detail;
        // this.filterAccountLookup=event.detail;
        console.log('this.selectedAccount' + this.selectedAccount);
        this.accId = event.detail;
        getAccDetails({ accountId: this.selectedAccount })
            .then(result => {

                this.account = result;
                this.showSpinner = false;
                this.showAccDetail = true;
            })
            .catch(error => {
                console.log(error);
            });
    }

    handleDateChangeTask(event) {
        let element = this.dailyTasks.find((ele) => ele.Id === event.target.dataset.id);
        let tempList = JSON.parse(JSON.stringify(this.dailyTasks));
        tempList.map((e) => {
            if (e.Id === event.target.dataset.id) {
                e.StartDateTime__c = event.target.value;
            }
        });
        this.dailyTasks = tempList;

        //this.datechangedIdList++;
        // this.dateIdList.push(event.target.dataset.id);

        // let allOutcomes = this.template.querySelectorAll(".slds-hide");
        // const selectedRowId = event.target.dataset.id;
        // for (var i = 0; i < allOutcomes.length; i++) {
        // let outcomeCells = allOutcomes[i].dataset.id;

        // if (outcomeCells == selectedRowId) {
        //     allOutcomes[i].classList.remove("slds-hide");
        //     allOutcomes[i].classList.add("slds-show");
        //     break;
        // }
        // }
    }
}