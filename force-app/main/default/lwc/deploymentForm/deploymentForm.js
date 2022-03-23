import { LightningElement, track } from 'lwc';
import getContactDetails from '@salesforce/apex/DeploymentFormController.getContactDetails';
import getContact from '@salesforce/apex/DeploymentFormController.getContact';
import saveDeployments from '@salesforce/apex/DeploymentFormController.saveDeployments';

import { ShowToastEvent } from "lightning/platformShowToastEvent";



export default class DeploymentForm extends LightningElement {
   @track yearOptions = [];
   disableSave = false;
    get monthOptions() {
        return [
            { label: 'January', value: 'January' },
            { label: 'February', value: 'February' },
            { label: 'March', value: 'March' },
            { label: 'April', value: 'April' },
            { label: 'May', value: 'May' },
            { label: 'June', value: 'June' },
            { label: 'July', value: 'July' },
            { label: 'August', value: 'August' },
            { label: 'September', value: 'September' },
            { label: 'October', value: 'October' },
            { label: 'November', value: 'November' },
            { label: 'December', value: 'December' },
        ];
    }
    get weekOptions() {
        return [
            { label: '1st to 7th', value: 'Week_1' },
            { label: '1st to  14th', value: 'Week_2' },
            { label: '1st to  21st', value: 'Week_3' },
            { label: 'Full Month', value: 'Week_4' }
            //{ label: 'Week 5', value: 'Week_5' },
        ];
    }


    @track showSpinner = false;
    @track selectedYear = '';
    @track calYear = null;
    @track selectedMonth = '';
    @track selectedWeek = '';
    @track selectedAccount = '';
    @track showVaDep = false;

    @track errMessage = 'No Data found';

    connectedCallback() {
        let fy = this.getCurrentFiscalYear();
        // let label1 = 'FY - ' + (fy-2);
        // let label2 = 'FY - ' + (fy-1);
        // let label3 = 'FY - ' + (fy);
        // let label4 = 'FY - ' + (fy+1);
        // let label5 = 'FY - ' + (fy+2);
        // this.yearOptions = [{label : label1,value : (fy-2).toString()},
        //                     {label : label2,value : (fy-1).toString()},
        //                     {label : label3,value : fy.toString()},
        //                     {label : label4,value : (fy+1).toString()},
        //                     {label : label5,value : (fy+2).toString()}];
        this.yearOptions = [{label : (fy-2),value : (fy-2)},
        {label : (fy-1),value : (fy-1)},
        {label : fy,value : fy},
        {label : (fy+1),value : (fy+1)},
        {label : (fy+2),value : (fy+2)}];
    }

    handleAccountSelection(event) {
        this.selectedAccount = event.detail;
    }


    handleYearChange(event) {
        this.selectedYear = parseInt(event.detail.value);
        //this.calYear = parseInt(this.selectedYear);
    }
    handleMonthChange(event) {
        this.selectedMonth = event.detail.value;
        if(this.selectedMonth != 'January' && this.selectedMonth != 'February' && this.selectedMonth != 'March') {
            //this.calYear = this.calYear - 1 ;
        }
    }
    handleWeekChange(event) {
        this.selectedWeek = event.detail.value;
    }
    @track allListData = [];
    submitForm() {
        if (this.selectedAccount !== undefined && this.selectedYear !== undefined && this.selectedMonth !== undefined
            && this.selectedWeek !== undefined && this.selectedAccount !== '' && this.selectedYear !== ''
            && this.selectedMonth !== '' && this.selectedWeek !== '') {
            this.showSpinner = true;
            this.showVaDep = false;
            this.allListData = [];
            getContactDetails({ accId: this.selectedAccount, year: this.selectedYear, month: this.selectedMonth })
                .then((result) => {
                    let docList = [];
                    getContact({ accId: this.selectedAccount })
                        .then((data) => {
                            docList = data;
                            this.allListData = JSON.parse(JSON.stringify(result));



                            var datalist = [];
                            for (let key in result) {
                                // Preventing unexcepted data
                                if (result.hasOwnProperty(key)) { // Filtering the data in the loop 
                                    for (var i = 0; i < docList.length; i++) {
                                        if (docList[i].Id == key) {
                                            datalist.push({ "Id": key, "Name": docList[i].Name, "value": result[key] });
                                            break
                                        }
                                    }

                                }
                            }
                            this.allListData = datalist;
                            if(this.allListData.length<1){
                                this.errMessage='No Doctor found';
                            }else{
                                this.errMessage='No data found';
                            }
                        });

                    this.showVaDep = true;
                    this.showSpinner = false;
                    


                }).catch((err) => {
                    console.log(err);
                });
        } else {
            this.showSpinner = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error",
                    message: "Please fill all the fields.",
                    variant: "error"
                })
            );
        }
    }

    resetForm() {
        this.selectedAccount = '';
        this.selectedYear = '';
        this.calYear = null;
        this.selectedMonth = '';
        this.selectedWeek = '';
        this.template.querySelector('c-daily-reporting-account-lookup').handleRemovePill();
        this.allListData = [];
        this.showVaDep = false;
    }

    saveRecords() {
        this.disableSave = true;
        this.showSpinner = true;
        let updateprdlist = [];
        let alldoctordata = this.template.querySelectorAll('c-deployment-table');

        let allVadata = this.template.querySelector('c-deployment-form-va').updateList;
        updateprdlist.push(...allVadata);


        alldoctordata.forEach(element => {
            //updateprdlist.push(element.updateList);
            //if(element.updateList.)
            updateprdlist.push(...element.updateList);
        });
        saveDeployments({ depList: updateprdlist })
            .then(result => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Saved",
                        message: "Deployments updated.",
                        variant: "success"
                    })
                );
                this.disableSave = false;
                this.showSpinner = false;
                this.resetForm();

            })
            .catch(err => {
                this.showSpinner = false;
                console.log(err);
                 this.disableSave = false;

            })
    }
    // get current fiscal year
 getCurrentFiscalYear() {
    let today = new Date();
    let currentMonth = today.getMonth();
    let fiscalYear = '';
    if (currentMonth >= 0 && currentMonth <= 2) {
        fiscalYear = today.getFullYear() - 1;
    } else {
        fiscalYear = today.getFullYear();
    }
    return fiscalYear;
}
}