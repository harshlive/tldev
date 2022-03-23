import { LightningElement, track, api, wire } from 'lwc';
import fetchRecordsForWeeklyPlan from '@salesforce/apex/DailyReportingController.fetchRecordsForWeeklyPlan';
import getAccDetails from '@salesforce/apex/DailyReportingController.getAccDetails';
import insertWeeklyTaskList from '@salesforce/apex/DailyReportingController.insertWeeklyTaskList';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getPickListValues from "@salesforce/apex/DailyReportingController.getPickListValues";
import getPickList from "@salesforce/apex/DailyReportingController.getPickList";
import showTaskList from "@salesforce/apex/DailyReportingController.showTaskList";
import FORM_FACTOR from "@salesforce/client/formFactor";
import saveTaskLwc from "@salesforce/apex/MilestoneRecordPage.saveTaskLwc";
import { refreshApex } from '@salesforce/apex';


export default class WeeklyPlanning extends LightningElement {

    @track defaultDate = new Date().toISOString().split('T')[0];
    @track selectedAccount;
    @track showAccDetail = false;
    @track showTable = false;
    @track isModalOpen = false;
    @track showSpinner = false;
    @track myList = [];
    @track myTaskList = [];
    @track account = [];
    @track prodWidthStyle;
    @track variable = false;
    keyIndex = 0;

    @track categoryOptions = [];
    @track category;
    @track activityStartDate;
    //@track statusOptions = [];
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
    @track mindate;
    @track maxdate;

    disableBtn = false;
    //value ='';

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
        /*getPickList({ objectName: "Task", fieldName: "Status" })
        .then((result) => {
            result.forEach((element) =>
            this.statusOptions.push({ label: element, value: element })
            );
            console.log(this.options);
        })
        .catch((error) => {
            this.error = error;
            console.log(this.error);
        });*/
        this.getTaskDetails();

        let today = new Date();
        let ddMin = today.getDate();
        let mm = today.getMonth() + 1;
        let y = today.getFullYear();
        this.mindate = y + '-' + mm + '-' + ddMin;
        console.log("mindate", this.mindate);

        let todayMax = new Date();
        let ddMinn = todayMax.getDate();
        let ddMax = todayMax.setDate(today.getDate() + 30);
        let mmMax = todayMax.getMonth() + 2;
        let yMax = todayMax.getFullYear();
        this.maxdate = yMax + '-' + mmMax + '-' + ddMinn;
        console.log("maxdate", this.maxdate);
    }

    getTaskDetails() {
        console.log('11');
        showTaskList()
            .then((result) => {
                this.myTaskList = result;
                console.log("result");
                console.log(this.myTaskList);
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

    get options() {
        return [
            { label: 'High', value: 'High' },
            { label: 'Normal', value: 'Normal' },
            { label: 'Low', value: 'Low' },
        ];
    }

    get statusOptions() {
        return [
            { label: 'Not Started', value: 'Not Started' },
            { label: 'In Progress', value: 'In Progress' }
        ];
    }

    handleChange(event) {
        this.value = event.detail.value;
        var uniqueKey = event.target.dataset.id;
        let tempList = JSON.parse(JSON.stringify(this.myList));
        tempList.map(e => {
            console.log('e.uniKey::' + e.uniKey);
            console.log('uniqueKey::' + uniqueKey);

            if (e.uniKey === uniqueKey) {
                e.Priority = this.value;
            }
        })
        this.myList = tempList;
    }

    handleDateChange(event) {
        this.dateVal = event.target.value;
        console.log('nnn');
        var uniqueKey = event.target.dataset.id;
        let tempList = JSON.parse(JSON.stringify(this.myList));
        tempList.map(e => {
            console.log('e.uniKey::' + e.uniKey);
            console.log('uniqueKey::' + uniqueKey);

            if (e.uniKey === uniqueKey) {
                e.StartDateTime__c = this.dateVal;
                console.log('e.StartDateTime__c::' + e.StartDateTime__c);
            }
        })
        this.myList = tempList;
    }

    handleAccountSelection(event) {
        this.selectedAccount = event.detail;

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

    showTaskTable() {
        this.showSpinner = true;
        this.myList = [];
        this.disableBtn = false;
        fetchRecordsForWeeklyPlan({ accountId: this.selectedAccount })
            .then(result => {
                this.myList = result;
                this.showSpinner = false;
                this.showTable = true;
            })
            .catch(error => {
                console.log(error);
            });
    }
    handleSelectChange(event) {
        let element = this.myList.find(ele => ele.uniKey === event.target.dataset.id);
        let tempList = JSON.parse(JSON.stringify(this.myList));
        if (event.target.checked) {
            tempList.map(e => {
                if (e.uniKey === event.target.dataset.id) {
                    e.Select = true;
                }
            })
        } else {
            tempList.map(e => {
                if (e.uniKey === event.target.dataset.id) {
                    e.Select = false;
                }
            })
        }
        this.myList = tempList;
    }

    handleCategoryChange(event) {
        let eventData = event.detail;
        let pickValue = event.detail.selectedValue;
        let uniqueKey = event.detail.key;
        let element = this.myList.find(ele => ele.uniKey === uniqueKey);
        let tempList = JSON.parse(JSON.stringify(this.myList));
        tempList.map(e => {
            if (e.uniKey === uniqueKey) {
                e.Category__c = pickValue;
            }
        })
        this.myList = tempList;

    }

    handleStatusChange(event) {
        let eventData = event.detail;
        let pickValue = event.detail.value;
        let uniqueKey = event.target.dataset.id;
        let element = this.myList.find((ele) => ele.Id === uniqueKey);
        let tempList = JSON.parse(JSON.stringify(this.myList));
        tempList.map((e) => {
            if (e.uniKey === uniqueKey) {
                e.Status = pickValue;
                console.log('e.Status::' + e.Status);
            }
        });
        this.myList = tempList;
    }


    handleProductPicklistChange(event) {
        event.stopPropagation();
        const detail = event.detail.selectedListData;
        const key = event.detail.key;
        let productPicklistVal = '';
        if (detail.length > 0) {
            productPicklistVal = detail.join(';');
            let tempList = JSON.parse(JSON.stringify(this.myList));
            tempList.map(e => {
                if (e.uniKey === key) {
                    e.Product2__c = productPicklistVal;
                }
            })
            this.myList = tempList;
        }
        if (detail.length === 0) {

            let tempList = JSON.parse(JSON.stringify(this.myList));
            tempList.map(e => {
                if (e.uniKey === key) {
                    e.Product2__c = '';
                }
            })
            this.myList = tempList;

        }
    }

    handleCommentChange(event) {
        let element = this.myList.find(ele => ele.uniKey === event.target.dataset.id);
        let tempList = JSON.parse(JSON.stringify(this.myList));
        tempList.map(e => {
            if (e.uniKey === event.target.dataset.id) {
                e.Comments__c = event.target.value;
            }
        })
        this.myList = tempList;

    }

    @track supportIdselection;
    handleSupportSelection(event) {
        this.supportIdselection = event.detail.selectedValue;
        let uniqueKey = event.detail.key;
        let element = this.myList.find(ele => ele.uniKey === uniqueKey);
        let tempList = JSON.parse(JSON.stringify(this.myList));
        tempList.map(e => {
            if (e.uniKey === uniqueKey) {
                e.Support__c = this.supportIdselection;
            }
        })
        this.myList = tempList;
    }

    submitReport(event) {
        let taskList = [];
        let tempList = JSON.parse(JSON.stringify(this.myList));
        for (let i = 0; i < tempList.length; i++) {
            console.log('tempList[i]::' + JSON.stringify(tempList[i]));
            if (tempList[i].Select) {
                if (tempList[i].Select == true) {
                    if (tempList[i].Product2__c == undefined || tempList[i].StartDateTime__c == undefined
                        || tempList[i].Comments__c == undefined || tempList[i].Category__c == undefined 
                        || tempList[i].Status == undefined || tempList[i].Priority == undefined) {
                        console.log('else select info');
                        let msg;
                        if (tempList[i].StartDateTime__c == undefined) {
                            msg = 'Date of Task';
                        } else if (tempList[i].Category__c == undefined) {
                            msg = 'Type of Task';
                        } else if (tempList[i].Product2__c == undefined) {
                            msg = 'Product';
                        } else if (tempList[i].Status == undefined) {
                            msg = 'Status';
                        } else if (tempList[i].Comments__c == undefined) {
                            msg = 'Objective of Task';
                        } else if (tempList[i].Priority == undefined) {
                            msg = 'Priority';
                        }
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Cannot Submit',
                                message: 'Please fill required fields - ' + msg,
                                variant: 'info'
                            })
                        );
                        this.disableBtn = false;
                        return;
                    } else {
                        if (new Date(tempList[i].StartDateTime__c) < new Date(this.mindate) || new Date(tempList[i].StartDateTime__c) > new Date(this.maxdate)) {
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Cannot Submit',
                                    message: 'Please select valid Date',
                                    variant: 'info'
                                })
                            );
                            return;
                        }
                        console.log('tempList[i].StartDateTime__c::' + tempList[i].StartDateTime__c);
                        let newTask = { 'sobjectType': 'Task' };
                        newTask.WhatId = tempList[i].AccountId;
                        newTask.Account__c = tempList[i].AccountId;
                        newTask.WhoId = tempList[i].Id;
                        newTask.Category__c = tempList[i].Category__c;
                        //newTask.Product__c=tempList[i].Product__c;
                        newTask.Product2__c = tempList[i].Product2__c;
                        newTask.Support__c = tempList[i].Support__c;
                        //newTask.Task_Type__c = 'In Field';
                        //newTask.Field_Non_Field__c= true;
                        newTask.Comments__c = tempList[i].Comments__c;
                        newTask.StartDateTime__c = tempList[i].StartDateTime__c;
                        newTask.Status = tempList[i].Status;
                        newTask.Priority = tempList[i].Priority;
                        taskList.push(newTask);
                        this.disableBtn = true;
                    }
                }
            }

        }

        if (taskList.length > 0) {
            insertWeeklyTaskList({ taskList: taskList })
                .then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: `Task added succesfully!`,
                            variant: 'success',
                        }),
                    );
                    this.showTable = false;
                    this.getTaskDetails();
                }
                )
                .catch(error => {
                    this.error = error;
                    console.log(this.error);
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
        }
    }

    handleClick(event) {
        let con = {};
        let index = 0;
        var contact = event.target.dataset.id;
        this.myList.forEach(e => {
            if (e.uniKey == contact) {
                con = { ...e };
                let arr = con.uniKey.split(':');
                con.uniKey = arr[0] + ':' + (parseInt(arr[1]) + 1);
                //con.Id = null;
                con.StartDateTime__c = null;
                con.Category__c = null;
                con.Product2__c = null;
                con.Status = null;
                con.Comments__c = null;
                con.Priority = null;
                con.Support__c = null;
                //e = { id: this.keyIndex,...contact };
            } else {
                index++;
            }
        })
        //this.variable = true;
        //++this.keyIndex;
        //var newItem = [{ id: this.keyIndex,...con }];
        //console.log('11 this.myList::'+JSON.stringify(this.myList));
        //this.myList.splice(index-1,0,con);
        this.myList.push(con);
        console.log('CON::' + JSON.stringify(con));
        console.log('22 this.myList::' + JSON.stringify(this.myList));

        /* let con = {};
        let index = 0;
        let k = 0;
        var contact = event.target.dataset.id;
        this.myList.forEach(e =>{
            if(e.uniKey == contact){ 
                con = {...e};
                let arr = con.uniKey.split(':');
                con.uniKey = arr[0] +':'+ (parseInt(arr[1])+1)
                //e = { id: this.keyIndex,...contact };
                if(index != 0){
                    k++;
                }
            }else{
                index++;
            }
        }) 
        console.log('11 this.myList::'+JSON.stringify(this.myList));
        this.myList.splice(index-1+k,0,con);
        console.log('22 this.myList::'+JSON.stringify(this.myList));
        */

    }

    addCategoryChange(event) {
        this.category = event.detail.value;
    }

    dateChange(event) {
        this.activityStartDate = event.target.value;
    }

    addStatusChange(event) {
        this.status = event.detail.value;
    }

    commentsChange(event) {
        this.comments = event.target.value;
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

    @track addContact;
    addContactSelection(event) {
        this.addContact = event.detail.selectedValue;
    }

    @track addSupport;
    addSupportSelection(event) {
        this.addSupport = event.detail.selectedValue;
    }

    @track campaignName;
    addCampaignChange(event) {
        this.campaignName = event.detail.value;
    }

    closeModal() {
        this.isModalOpen = false;
        //mkt change-3
        // this.isMarketing=false;
        this.campaignName = null;
        this.activityStartDate = null;
    }

    onDoubleClickEdit() {
        this.myTaskList.forEach((element) => {
            if (element.Status == 'Complete') {
                element.isEdited = false;
            }
            else {
                element.isEdited = true;
            }
        }
        );
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
                this.myTaskList.some(
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
            let toSaveList = this.myTaskList;
            toSaveList.forEach((element, index) => {
                if (element.Subject === "") {
                    toSaveList.splice(index, 1);
                }
            });

            this.myTaskList = toSaveList;
            let tempList = JSON.parse(JSON.stringify(this.myTaskList));
            for (let i = 0; i < tempList.length; i++) {
                console.log('tempList[i]::' + JSON.stringify(tempList[i]));
                /*if (tempList[i].StartDateTime__c < this.mindate || tempList[i].StartDateTime__c > this.maxdate) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Cannot Submit',
                            message: 'Please select valid Date',
                            variant: 'info'
                        })
                    );
                    this.toggleSaveLabel = "Save";
                    return;
                } else */{
                    let taskList = [];
                    let tempList = JSON.parse(JSON.stringify(this.myTaskList));
                    //for( let i= 0 ; i < tempList.length ; i++){
                    console.log('tempList[i]::' + JSON.stringify(tempList[i].Comments__c));
                    console.log('tempList[i]::' + JSON.stringify(tempList[i].Product2__c));
                    if (tempList[i].Comments__c == undefined || tempList[i].Product2__c == undefined || tempList[i].Comments__c == "" || tempList[i].Product2__c == "") {
                        let msg;
                        if (tempList[i].Comments__c == undefined || tempList[i].Comments__c == "") {
                            msg = 'Details';
                        } else if (tempList[i].Product2__c == undefined || tempList[i].Product2__c == ""){
                            msg = 'Product';
                        }
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Cannot Submit',
                                message: 'Please fill required fields - ' + msg,
                                variant: 'info'
                            })
                        );
                        this.disableBtn = false;
                        this.toggleSaveLabel = "Save";
                        return;
                    }
                }
                //}
            }
            console.log("save LWC");
            console.log(" this.myTaskList::" + JSON.stringify(this.myTaskList));
            saveTaskLwc({ records: this.myTaskList,account:  this.selectedAccount })
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
                    //this.getTaskRecords();
                    console.log("after get rec");
                    this.dateIdList = [];
                    this.commentsIdList = [];
                    this.getTaskDetails();
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
            /*let tempList  = JSON.parse(JSON.stringify(this.myTaskList));
            for( let i= 0 ; i < tempList.length ; i++){
                console.log('tempList[i]::'+JSON.stringify(tempList[i]));
                if(tempList[i].StartDateTime__c < this.mindate || tempList[i].StartDateTime__c > this.maxdate){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Cannot Submit',
                            message: 'Please select valid Date',
                            variant: 'info'
                        })
                    );
                    return;
                }else{
                console.log("save LWC");
                console.log(" this.myTaskList::"+JSON.stringify(this.myTaskList));
                saveTaskLwc({ records: this.myTaskList })
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
                    //this.getTaskRecords();
                    console.log("after get rec");
                    this.dateIdList = [];
                    this.commentsIdList = [];
                    this.getTaskDetails();
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
            }*/

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
        this.getTaskDetails();
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

    handleCategoryChangeTask(event) {
        let eventData = event.detail;
        let pickValue = event.detail.selectedValue;
        let uniqueKey = event.detail.key;
        let element = this.myTaskList.find((ele) => ele.Id === uniqueKey);
        let tempList = JSON.parse(JSON.stringify(this.myTaskList));
        tempList.map((e) => {
            if (e.Id === uniqueKey) {
                e.Category__c = pickValue;
            }
        });
        this.myTaskList = tempList;
    }

    handleChangeTask(event) {
        this.value = event.detail.value;
        var uniqueKey = event.target.dataset.id;
        let tempList = JSON.parse(JSON.stringify(this.myTaskList));
        tempList.map(e => {
            if (e.uniKey === uniqueKey) {
                e.Priority = this.value;
            }
        })
        this.myTaskList = tempList;
    }

    handleDateChangeTask(event) {
        let element = this.myTaskList.find((ele) => ele.Id === event.target.dataset.id);
        let tempList = JSON.parse(JSON.stringify(this.myTaskList));
        tempList.map((e) => {
            if (e.Id === event.target.dataset.id) {
                e.StartDateTime__c = event.target.value;
            }
        });
        this.myTaskList = tempList;

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
        let element = this.myTaskList.find((ele) => ele.Id === event.target.dataset.id);
        let tempList = JSON.parse(JSON.stringify(this.myTaskList));
        tempList.map((e) => {
            if (e.Id === event.target.dataset.id) {
                e.Due_Date_Comments__c = event.target.value;
                //e.IsReminderSet = false;
                //e.ReminderDateTime = null;
            }
        });
        this.myTaskList = tempList;
        this.commentsChangedIdList++;

        this.commentsIdList.push(event.target.dataset.id);
    }

    handleChangeTask(event) {
        this.value = event.detail.value;
        var uniqueKey = event.target.dataset.id;
        let tempList = JSON.parse(JSON.stringify(this.myTaskList));
        tempList.map(e => {
            if (e.Id === uniqueKey) {
                e.Priority = this.value;
            }
        })
        this.myTaskList = tempList;
    }

    handleStatusChangeTask(event) {
        let eventData = event.detail;
        let pickValue = event.detail.value;
        let uniqueKey = event.target.dataset.id;
        let element = this.myTaskList.find((ele) => ele.Id === uniqueKey);
        let tempList = JSON.parse(JSON.stringify(this.myTaskList));
        tempList.map((e) => {
            if (e.Id === uniqueKey) {
                e.Status = pickValue;
            }
        });
        this.myTaskList = tempList;
    }

    handleCommentChangeTask(event) {
        let element = this.myTaskList.find((ele) => ele.Id === event.target.dataset.id);
        let tempList = JSON.parse(JSON.stringify(this.myTaskList));
        tempList.map((e) => {
            if (e.Id === event.target.dataset.id) {
                e.Comments__c = event.target.value;
            }
        });
        this.myTaskList = tempList;
        //element.Subject = event.target.value;
        //this.myTaskList = [...this.myTaskList];
    }

    @track whoIdselection;
    handleContactSelection(event) {
        this.whoIdselection = event.detail.selectedValue;
        let uniqueKey = event.detail.key;
        let element = this.myTaskList.find((ele) => ele.Id === uniqueKey);
        let tempList = JSON.parse(JSON.stringify(this.myTaskList));
        tempList.map((e) => {
            if (e.Id === uniqueKey) {
                e.Contact__c = this.whoIdselection;
                this.accId = e.WhatId;
            }
        });
        this.myTaskList = tempList;
        this.filterContactLookup = "accountid = '" + this.accId + "'";

    }

    handleProductPicklistChangeTask(event) {
        event.stopPropagation();
        const detail = event.detail.selectedListData;
        const key = event.detail.key;
        let productPicklistVal = "";
        if (detail.length > 0) {
            productPicklistVal = detail.join(";");
            let tempList = JSON.parse(JSON.stringify(this.myTaskList));
            tempList.map((e) => {
                if (e.Id === key) {
                    e.Product2__c = productPicklistVal;
                }
            });
            this.myTaskList = tempList;
        }
        if (detail.length === 0) {
            let tempList = JSON.parse(JSON.stringify(this.myTaskList));
            tempList.map((e) => {
                if (e.Id === key) {
                    e.Product2__c = "";
                }
            });
            this.myTaskList = tempList;
        }
    }

    @track ownerIdselection;
    handleUserSelection(event) {
        this.ownerIdselection = event.detail.selectedValue;
        let uniqueKey = event.detail.key;
        let element = this.myTaskList.find((ele) => ele.Id === uniqueKey);
        let tempList = JSON.parse(JSON.stringify(this.myTaskList));
        tempList.map((e) => {
            if (e.Id === uniqueKey) {
                e.OwnerId = this.ownerIdselection;
            }
        });
        this.myTaskList = tempList;
    }

    @track supportIdselection;
    handleSupportSelectionTask(event) {
        this.supportIdselection = event.detail.selectedValue;
        let uniqueKey = event.detail.key;
        let element = this.myTaskList.find((ele) => ele.Id === uniqueKey);
        let tempList = JSON.parse(JSON.stringify(this.myTaskList));
        tempList.map((e) => {
            if (e.Id === uniqueKey) {
                e.Support__c = this.supportIdselection;
            }
        });
        this.myTaskList = tempList;
    }

    handleCategoryChangeTask(event) {
        let eventData = event.detail;
        let pickValue = event.detail.selectedValue;
        let uniqueKey = event.detail.key;
        let element = this.myTaskList.find((ele) => ele.Id === uniqueKey);
        let tempList = JSON.parse(JSON.stringify(this.myTaskList));
        tempList.map((e) => {
            if (e.Id === uniqueKey) {
                e.Category__c = pickValue;
                console.log('e.Category__c::' + e.Category__c);
            }
        });
        this.myTaskList = tempList;
    }

}