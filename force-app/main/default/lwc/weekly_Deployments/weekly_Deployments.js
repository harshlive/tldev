import { LightningElement, track } from "lwc";
import fetchRecords from "@salesforce/apex/WeeklyDeploymentsController.fetchRecords";
import getUserList from "@salesforce/apex/MyTeamDailyTaskController.getUserList";

export default class MyTeamDailyTask extends LightningElement {
  @track teamUser = [{ label: "--None--", value: "" }];
  @track monthOptions = [
    { label: "January", value: "January" },
    { label: "February", value: "February" },
    { label: "March", value: "March" },
    { label: "April", value: "April" },
    { label: "May", value: "May" },
    { label: "June", value: "June" },
    { label: "July", value: "July" },
    { label: "August", value: "August" },
    { label: "September", value: "September" },
    { label: "October", value: "October" },
    { label: "November", value: "November" },
    { label: "December", value: "December" }
  ];
  @track yearOptions = [
    { label: "2019", value: "2019" },
    { label: "2020", value: "2020" },
    { label: "2021", value: "2021" },
    { label: "2022", value: "2022" },
    { label: "2023", value: "2023" },
    { label: "2024", value: "2024" },
    { label: "2025", value: "2025" },
    { label: "2026", value: "2026" },
    { label: "2027", value: "2027" },
    { label: "2028", value: "2028" },
    { label: "2029", value: "2029" },
    { label: "2030", value: "2030" }
  ];

  @track selectedYear;
  @track selectedMonth;
  @track myList = [];
  @track showSpinner = false;
  @track selectedUserId;
  @track weeklyCount = {
    week1: 0,
    week2: 0,
    week3: 0,
    week4: 0,
    week5: 0,
    total: 0
  };
  connectedCallback() {
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
  }

  handleUserChange(event) {
    console.log("user val: " + event.target.value);
    this.selectedUserId = event.target.value;
  }
  handleYearChange(event) {
    console.log("Year val: " + event.target.value);
    this.selectedYear = event.target.value;
  }

  handleMonthChange(event) {
    console.log("user val: " + event.target.value);
    this.selectedMonth = event.target.value;
  }
  handleUserSelection(event) {
    console.log("user val: " + event.detail);
    this.selectedUserId = event.detail;
  }
  showTask(event) {
    this.showSpinner = true;
    fetchRecords({
      month: this.selectedMonth,
      user: this.selectedUserId,
      year: parseInt(this.selectedYear)
    })
      .then((result) => {
        if (result != null) {
          console.log("Task result: " + result);
          this.myList = result;
          this.myList.forEach((element) => {
            if (!element.Week_1__c) {
              element.Week_1__c = 0;
            }
            if (!element.Week_2__c) {
              element.Week_2__c = 0;
            }
            if (!element.Week_3__c) {
              element.Week_3__c = 0;
            }
            if (!element.Week_4__c) {
              element.Week_4__c = 0;
            }
            if (!element.Week_5__c) {
              element.Week_5__c = 0;
            }
            if (!element.Month_Total__c) {
              element.Month_Total__c = 0;
            }
          });
          this.myList.forEach((element) => {
            this.weeklyCount.week1 += element.Week_1__c;
            this.weeklyCount.week2 += element.Week_2__c;
            this.weeklyCount.week3 += element.Week_3__c;
            this.weeklyCount.week4 += element.Week_4__c;
            this.weeklyCount.week5 += element.Week_5__c;
            this.weeklyCount.total += element.Month_Total__c;
          });
          this.showSpinner = false;
        } else {
          this.showSpinner = false;
          this.myList = [];
        }
      })
      .catch((error) => {
        this.error = error;
        this.record = undefined;
        console.log("err " + this.error);
        this.showSpinner = false;
      });
  }
}