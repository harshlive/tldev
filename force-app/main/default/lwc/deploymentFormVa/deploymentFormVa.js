import { LightningElement, track, api } from 'lwc';

import getVaDeployments from '@salesforce/apex/DeploymentFormController.getVaDeployments';

export default class DeploymentFormVa extends LightningElement {

    @api accId = '';
    @api selectedYear = '';
    @api selectedMonth = '';
    @api weekName = '';
    @track productShowData = [];

    @track isWeek1 = false;
    @track isWeek2 = false;
    @track isWeek3 = false;
    @track isWeek4 = false;
    @track isWeek5 = false;
    @track totalValue = 0;

    @track showValueData = [];
    @track showSpinner = false;
    connectedCallback() {
        //0016D00000WnVJKQA3
        //getVaDeployments({accId:this.accId , year:this.selectedYear , month:this.selectedMonth})
        this.showSpinner = true;
        getVaDeployments({ accId: this.accId, year: this.selectedYear, month: this.selectedMonth })
            .then(result => {

                let dataList = [];
                for (let key in result) {

                    // Preventing unexcepted data
                    if (result.hasOwnProperty(key)) { // Filtering the data in the loop

                        let showValueItem = {};
                        showValueItem.prodName = result[key].Product_Name__c;
                        if (this.weekName === 'Week_1') {
                            showValueItem.quantity = result[key].Week_1__c;
                        } else if (this.weekName === 'Week_2') {
                            showValueItem.quantity = result[key].Week_2__c;
                        } else if (this.weekName === 'Week_3') {
                            showValueItem.quantity = result[key].Week_3__c;
                        } else if (this.weekName === 'Week_4') {
                            showValueItem.quantity = result[key].Week_4__c;
                        } else if (this.weekName === 'Week_5') {
                            showValueItem.quantity = result[key].Week_5__c;
                        }
                        this.showValueData.push(showValueItem);


                        if (result[key].Id != undefined) {
                            dataList.push({
                                Product_Name__c: result[key].Product_Name__c, Product_Family__c: result[key].Product_Family__c,
                                Account__c: result[key].Account__c, Year__c: result[key].Year__c, Month__c: result[key].Month__c,
                                Id: result[key].Id,
                                Week_1__c: result[key].Week_1__c,
                                Week_2__c: result[key].Week_2__c,
                                Week_3__c: result[key].Week_3__c,
                                Week_4__c: result[key].Week_4__c,
                                Week_5__c: result[key].Week_5__c
                            });
                        } else {
                            dataList.push({
                                Product_Name__c: result[key].Product_Name__c, Product_Family__c: result[key].Product_Family__c,
                                Account__c: result[key].Account__c, Year__c: result[key].Year__c, Month__c: result[key].Month__c,
                                Week_1__c: result[key].Week_1__c,
                                Week_2__c: result[key].Week_2__c,
                                Week_3__c: result[key].Week_3__c,
                                Week_4__c: result[key].Week_4__c,
                                Week_5__c: result[key].Week_5__c
                            });
                        }
                    }
                }
                this.productShowData = dataList;

                this.calculateTotalValue();
                this.showSpinner = false;

            })
            .catch(Error => {
                console.log(Error);
                this.showSpinner = false;
            })


        if (this.weekName === 'Week_1') {
            this.isWeek1 = true;
        } else if (this.weekName === 'Week_2') {
            this.isWeek2 = true;
        } else if (this.weekName === 'Week_3') {
            this.isWeek3 = true;
        } else if (this.weekName === 'Week_4') {
            this.isWeek4 = true;
        } else if (this.weekName === 'Week_5') {
            this.isWeek5 = true;
        }
    }
    @api updateList = [];
    changeQuantity(event) {
        let qtynew = event.target.value;

        for (var i = 0; i < this.showValueData.length; i++) {
            if (this.showValueData[i].prodName == event.target.dataset.item) {
                this.showValueData[i].quantity = qtynew;
            }
        }

        let ispresent = false;
        for (var i = 0; i < this.updateList.length; i++) {
            if (this.updateList[i].Product_Name__c == event.target.dataset.item) {
                ispresent = true;
                if (this.weekName === 'Week_1') {
                    this.updateList[i].Week_1__c = qtynew;
                } else if (this.weekName === 'Week_2') {
                    this.updateList[i].Week_2__c = qtynew;
                } else if (this.weekName === 'Week_3') {
                    this.updateList[i].Week_3__c = qtynew;
                } else if (this.weekName === 'Week_4') {
                    this.updateList[i].Week_4__c = qtynew;
                } else if (this.weekName === 'Week_5') {
                    this.updateList[i].Week_5__c = qtynew;
                }
                break;
            }
        }

        if (ispresent == false) {
            let newPrdTest = {};
            for (var i = 0; i < this.productShowData.length; i++) {
                if (this.productShowData[i].Product_Name__c == event.target.dataset.item) {

                    newPrdTest = { ...this.productShowData[i] };

                    if (this.weekName === 'Week_1') {
                        newPrdTest.Week_1__c = qtynew;
                    } else if (this.weekName === 'Week_2') {
                        newPrdTest.Week_2__c = qtynew;
                    } else if (this.weekName === 'Week_3') {
                        newPrdTest.Week_3__c = qtynew;
                    } else if (this.weekName === 'Week_4') {
                        newPrdTest.Week_4__c = qtynew;
                    } else if (this.weekName === 'Week_5') {
                        newPrdTest.Week_5__c = qtynew;
                    }
                    break;
                }
            }
            this.updateList.push(newPrdTest);
        }

        this.calculateTotalValue();
    }

    calculateTotalValue() {
        this.totalValue = 0;
        let showValue = 0;
        for (var i = 0; i < this.showValueData.length; i++) {
            if (!isNaN(this.showValueData[i].quantity)){
                if (this.showValueData[i].quantity != undefined && this.showValueData[i].quantity != '') {
                    showValue += Number(this.showValueData[i].quantity);
                }
            }
        }  
        this.totalValue = showValue;
    }

}