import { LightningElement } from 'lwc';
import xlsxJS from '@salesforce/resourceUrl/SheetJs';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import createRecords from '@salesforce/apex/AccountPlanController.createRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AccountPlanUploader extends LightningElement {
    librariesLoaded = false;
    renderedCallback() {
        console.log("renderedCallback xlsx");
        if (this.librariesLoaded) return;
        this.librariesLoaded = true;
        Promise.all([loadScript(this, xlsxJS)])
            .then(() => {
                console.log("success");
            })
            .catch(error => {
                console.log("failure");
            });
    }
    openfileUpload(event) {
        const file = event.target.files[0];
        var reader = new FileReader();
        var context = this;
        reader.onload = (event) => {
            var data = event.target.result;
            var workbook = XLSX.read(data, {
                type: 'binary'
            });
            workbook.SheetNames.forEach(function (sheetName) {
                console.log(context);
                var XL_row_object = XLSX.utils.sheet_to_json(workbook.Sheets[sheetName], { header: 1 });
                console.log(XL_row_object);
                var curYear = XL_row_object[0][1];
                var months = [];
                var deps = [];
                for (var i = 2; i < XL_row_object[0].length; i++) {
                    if (XL_row_object[0][i] != null) {
                        months.push(XL_row_object[0][i]);
                    }
                }
                console.log(months);
                for (var k = 2; k < XL_row_object.length; k++) {
                    var low = 0;
                    if (XL_row_object[k].length != 0) {
                        for (var p = 0; p < months.length; p++) {
                            var itr = parseInt((XL_row_object[1].length - 3) / months.length);
                            for (var l = low; l < low + itr; l++) {
                                var dep = {
                                    account: XL_row_object[k][0].trim(),
                                    user: XL_row_object[k][2].trim(),
                                    month: months[p],
                                    year: curYear,
                                    pName: XL_row_object[1][l + 3].trim(),
                                    pVal: XL_row_object[k][l + 3],

                                }
                                deps.push(dep);
                            }
                            low = itr;
                        }
                    }
                }
                console.log(deps);
                createRecords({
                    planLst: deps
                })
                    .then(result => {
                        console.log(result);
                        context.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: 'Plans have been uploaded in the system successfully',
                                variant: 'success'
                            })
                        );
                    })
                    .catch(error => {
                        console.log(error);
                        context.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error',
                                message: 'Some error occurred, Please contact admin',
                                variant: 'Error'
                            })
                        );
                    });
            })
        };

        reader.onerror = function (event) {
            console.error("File could not be read! Code " + event.target.error.code);
        };
        reader.readAsBinaryString(file)
    }
}