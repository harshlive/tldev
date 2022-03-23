import { LightningElement, track, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import readCSVFile from "@salesforce/apex/ReadCSVController.readCSVFile";

const columns = [
  { label: "Name", fieldName: "Name" },
  { label: "Industry", fieldName: "Industry" },
  { label: "Rating", fieldName: "Rating" },
  { label: "Type", fieldName: "Type" }
];

export default class ReadCSVLWC extends LightningElement {
  @api recordId;
  @track error;
  @track columns = columns;
  @track data;

  // accepted parameters
  get acceptedFormats() {
    return [".csv"];
  }

  docTypeValue = "SecondaryActuals";

  get docTypeOptions() {
    return [
      { label: "Secondary Monthly SAR", value: "SecondaryActuals" },
      { label: "Targets-Secondary", value: "SecondaryTargets" },
      { label: "Target and Actuals-Primary", value: "PrimaryTargets" }
    ];
  }

  handleDocTypeChange(event) {
    this.docTypeValue = event.detail.value;
  }

  handleUploadFinished(event) {
    // Get the list of uploaded files
    const uploadedFiles = event.detail.files;

    // calling apex class
    readCSVFile({
      idContentDocument: uploadedFiles[0].documentId,
      type: this.docTypeValue
    })
      .then((result) => {
        window.console.log(result);
        // this.data = result;
        if (result !== null) {
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Success!!",
              message: "Records updated based CSV file!!!",
              variant: "success"
            })
          );
        } else {
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Error!!",
              message: "Error occured, Plese check logs",
              variant: "error"
            })
          );
        }
      })
      .catch((error) => {});
  }
}