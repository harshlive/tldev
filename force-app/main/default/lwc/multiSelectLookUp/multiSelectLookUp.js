import { LightningElement, api, track } from 'lwc';
import retrieveRecords from '@salesforce/apex/MultiSelectLookupController.retrieveRecords';

let i=0;
export default class LwcMultiSelectLookup extends LightningElement {

    @track globalSelectedItems = []; 
    @api labelName;
    @api objectApiName; 
    @api fieldApiNames; 
    @api filterFieldApiName;
    @api iconName;  
    
    @track items = [];
    @track selectedItems = []; 

    @track previousSelectedItems = []; 
    @track value = []; 
    searchInput ='';    
    isDialogDisplay = false; 
    isDisplayMessage = false; 
    
    connectedCallback() {
            //         retrieveRecords({objectName: this.objectApiName,
            //             fieldAPINames: this.fieldApiNames,
            //             filterFieldAPIName: this.filterFieldApiName,
            //             strInput: "*"
            //             })
            // .then(result=>{ 
            // this.items = []; 
            // this.value = [];
            // this.previousSelectedItems = [];

            // if(result.length>0){
            //     result.map(resElement=>{
            //         this.items = [...this.items,{value:resElement.recordId, 
            //                                     label:resElement.recordName}];
            //         // this.globalSelectedItems.map(element =>{
            //         //     if(element.value == resElement.recordId){
            //         //         this.value.push(element.value);
            //         //         this.previousSelectedItems.push(element);                      
            //         //     }
            //         // });

            //     });
            //     const arrItems = this.items;
            //     this.globalSelectedItems = arrItems;
            //     this.previousSelectedItems = [];
            //     this.initializeValues();
                
            //     const evtCustomEvent = new CustomEvent('retrieve', { 
            //         detail: {arrItems}
            //         });
            //     this.dispatchEvent(evtCustomEvent);
            //     // this.isDialogDisplay = true; 
            //     // this.isDisplayMessage = false;
            // }
            // else{
            //     this.isDialogDisplay = false;
            //     this.isDisplayMessage = true;                    
            // }
            // })
            // .catch(error=>{
            // this.error = error;
            // this.items = undefined;
            // this.isDialogDisplay = false;
            // })


            

    }
    onchangeSearchInput(event){

        this.searchInput = event.target.value;
        if(this.searchInput.trim().length>0){
            retrieveRecords({objectName: this.objectApiName,
                            fieldAPINames: this.fieldApiNames,
                            filterFieldAPIName: this.filterFieldApiName,
                            strInput: this.searchInput
                            })
            .then(result=>{ 
                this.items = []; 
                this.value = [];
                this.previousSelectedItems = [];

                if(result.length>0){
                    result.map(resElement=>{
                        this.items = [...this.items,{value:resElement.recordId, 
                                                    label:resElement.recordName}];
                        this.globalSelectedItems.map(element =>{
                            if(element.value == resElement.recordId){
                                this.value.push(element.value);
                                this.previousSelectedItems.push(element);                      
                            }
                        });
                    });
                    this.isDialogDisplay = true; 
                    this.isDisplayMessage = false;
                }
                else{
                    this.isDialogDisplay = false;
                    this.isDisplayMessage = true;                    
                }
            })
            .catch(error=>{
                this.error = error;
                this.items = undefined;
                this.isDialogDisplay = false;
            })
        }else{
            this.isDialogDisplay = false;
        }                
    }

    handleCheckboxChange(event){
        let selectItemTemp = event.detail.value;
        
        console.log(' handleCheckboxChange  value=', event.detail.value);        
        this.selectedItems = []; 
        selectItemTemp.map(p=>{            
            let arr = this.items.find(element => element.value == p);
            if(arr != undefined){
                this.selectedItems.push(arr);
            }  
        });     
    }

    handleRemoveRecord(event){        
        const removeItem = event.target.dataset.item; 
        
        this.globalSelectedItems = this.globalSelectedItems.filter(item => item.value  != removeItem);
        const arrItems = this.globalSelectedItems;

        this.initializeValues();
        this.value =[]; 

        const evtCustomEvent = new CustomEvent('remove', {   
            detail: {removeItem,arrItems}
            });
        this.dispatchEvent(evtCustomEvent);
    }

    handleDoneClick(event){
        this.previousSelectedItems.map(p=>{
            this.globalSelectedItems = this.globalSelectedItems.filter(item => item.value != p.value);
        });
        
        this.globalSelectedItems.push(...this.selectedItems);        
        const arrItems = this.globalSelectedItems;
        
        this.previousSelectedItems = this.selectedItems;
        this.initializeValues();
        
        const evtCustomEvent = new CustomEvent('retrieve', { 
            detail: {arrItems}
            });
        this.dispatchEvent(evtCustomEvent);
    }

    handleCancelClick(event){
        this.initializeValues();
    }

    initializeValues(){
        this.searchInput = '';        
        this.isDialogDisplay = false;
    }
}