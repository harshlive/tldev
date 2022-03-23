import { LightningElement, track, api } from 'lwc';
export default class DeploymentTable extends LightningElement {

    //Sample format
    // @track productFamily = [{
    //     "index": "1", "Name": "Des", "productName": [{ "Name": "Flex", "qty": 11 }, { "Name": "VIVO Isar", "qty": 12 }, { "Name": "Ultima PC", "qty": 72 }, { "Name": "Ultima PC", "qty": 33 }, { "Name": "Elite", "qty": 56 }, { "Name": "PC", "qty": 31 }
    //         , { "Name": "PC Plus", "qty": 9 }, { "Name": "Racer CC", "qty": 23 }]
    // },
    // { "index": "2", "Name": "IVL", "productName": [{ "Name": "IVL", "qty": 111 }] },
    // { "index": "3", "Name": "OPN/NIC NANO", "productName": [{ "Name": "OPN NC", "qty": 23 }, { "Name": "NIC Nano", "qty": 32 }, { "Name": "ID", "qty": 56 }] },
    // { "index": "4", "Name": "Balloons", "productName": [{ "Name": "NC", "qty": 44 }, { "Name": "SC", "qty": 0 }, { "Name": "Radieon", "qty": 9 }, { "Name": "Ikazuci Zero", "qty": 28 }] },
    // { "index": "5", "Name": "PMBV", "productName": [{ "Name": "PMBV", "qty": 45 }] }];


    @track headerList = [];
    @api valueData;
    @track productShowData = [];
    @track isWeek1 = false;
    @track isWeek2 = false;
    @track isWeek3 = false;
    @track isWeek4 = false;
    @track isWeek5 = false;
    connectedCallback() {

        let index = 1;
        let showData = [];
        let headers = [];
        for (let key in this.valueData) {
            // Preventing unexcepted data

            if (this.valueData.hasOwnProperty(key)) { // Filtering the data in the loop 
                showData.push({ "index": index, "Name": key, "productName": this.valueData[key] });
                headers.push({ "hname": key })
                index++;
            }
        }
        this.headerList = headers;
        this.productShowData = showData;
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




    @track selectedDeployment;
    @api weekName = '';

    @api updateList = [];
    changeQuantity(event) {
        let qtynew = event.target.value;
        
        if(parseInt(qtynew) > 999) {
            alert('Entered value should be less than or equal to 999');
            event.target.value = 0;
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
                if (this.productShowData[i].Name == event.target.dataset.family) {
                    var prdList = this.productShowData[i].productName;
                    for (var j = 0; j < prdList.length; j++) {
                        if (prdList[j].Product_Name__c == event.target.dataset.item) {
                            newPrdTest = { ...prdList[j] };

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
                    break;
                }
            }
            this.updateList.push(newPrdTest);
        }
    }

}