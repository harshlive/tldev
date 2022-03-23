/* eslint-disable vars-on-top */
/* eslint-disable no-console */
import { LightningElement, wire, track, api } from "lwc";
import getPickList from "@salesforce/apex/DailyReportingController.getPickList";
export default class multiSelectPicklist extends LightningElement {
  @track options = [];
  @api prodOptions;
  @track error;
  @track dropdown =
    "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click";
  @track dataList;
  @track dropdownList =
    "slds-media slds-listbox__option slds-listbox__option_entity slds-listbox__option_has-meta";
  @track selectedValue = "Select";
  @track selectedListOfValues = "";

  @api uniqueKey;

  connectedCallback() {
    getPickList({objectName: "Task", fieldName: "Product2__c"})
    .then(data => {                     
      if (data) {
        this.dataList = data;
        for (let i = 0; i < this.dataList.length; i++) {
          this.options = [
            ...this.options,
            {
              value: this.dataList[i],
              label: this.dataList[i],
              isChecked: false,
              class: this.dropdownList
            }
          ];
        }
        let count = 0;
        this.options.forEach((elem) => {
          if (this.prodOptions) {
            if (this.prodOptions.split(";").indexOf(elem.value) > -1) {
              count = count + 1;
              elem.isChecked = true;
              elem.class =
                "slds-media slds-listbox__option slds-listbox__option_plain slds-media_small slds-media_center slds-is-selected";
            }
          }
        });
        ///console.log('optionslist==>' + JSON.stringify(this.options));
         
        if (count === 0) {
          this.selectedValue = "Select";
        } else if (count === 1) {
          this.selectedValue = count + " Category Selected";
        } else if (count > 1) {
          this.selectedValue = count + " Categories Selected";
        }
      }
                        
  })
  .catch(error => {
    this.error = error;
    this.options = undefined;
    console.log(this.error);
  });
  }
 

  openDropdown() {
    this.dropdown =
      "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open";
  }

  closeDropDown() {
    this.dropdown =
      "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click";
  }

  selectOption(event) {
    var isCheck = event.currentTarget.dataset.id;
    var label = event.currentTarget.dataset.name;
    var selectedListData = [];
    var selectedOption = "";
    var allOptions = this.options;
    var count = 0;

    for (let i = 0; i < allOptions.length; i++) {
      if (allOptions[i].label === label) {
        if (isCheck === "true") {
          allOptions[i].isChecked = false;
          allOptions[i].class = this.dropdownList;
        } else {
          allOptions[i].isChecked = true;
          allOptions[i].class =
            "slds-media slds-listbox__option slds-listbox__option_plain slds-media_small slds-media_center slds-is-selected";
        }
      }
      if (allOptions[i].isChecked) {
        selectedListData.push(allOptions[i].label);
        count++;
      }
    }
    if (count === 1) {
      selectedOption = count + " Category Selected";
    } else if (count > 1) {
      selectedOption = count + " Categories Selected";
    }

    this.options = allOptions;
    this.selectedValue = selectedOption;
    this.selectedListOfValues = selectedListData;
    //console.log(selectedListData);
    let key = this.uniqueKey;
    const selectedEvent = new CustomEvent("valuechanged", {
      detail: { selectedListData, key }
    });
    this.dispatchEvent(selectedEvent);
  }

  removeRecord(event) {
    var value = event.detail.name;
    var removedOptions = this.options;
    var count = 0;
    var selectedListData = [];
    for (let i = 0; i < removedOptions.length; i++) {
      if (removedOptions[i].label === value) {
        removedOptions[i].isChecked = false;
        removedOptions[i].class = this.dropdownList;
      }

      if (removedOptions[i].isChecked) {
        selectedListData.push(removedOptions[i].label);
        count++;
      }
    }

    var selectedOption;
    if (count === 1) {
      selectedOption = count + " Category Selected";
    } else if (count > 1) {
      selectedOption = count + " Categories Selected";
    } else if (count === 0) {
      selectedOption = "Select";
      selectedListData = "";
    }
    this.selectedListOfValues = selectedListData;
    this.selectedValue = selectedOption;
    this.options = removedOptions;
    //console.log(selectedListData);
    let key = this.uniqueKey;
    const selectedEvent = new CustomEvent("valuechanged", {
      detail: { selectedListData, key }
    });
    this.dispatchEvent(selectedEvent);
  }
}