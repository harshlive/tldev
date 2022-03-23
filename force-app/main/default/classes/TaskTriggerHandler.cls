public class TaskTriggerHandler {
    
    public static void onBeforeInsert(List<Task> taskList ){ 
        map<Id,String> accMap=new map<Id,String>();
        map<Id,String> conMap=new map<Id,String>();
        map<Id,String> userMap=new map<Id,String>();
        set<Id> accId=new set<Id>();
        set<Id> conId=new set<Id>();
        set<Id> userId=new set<Id>();
        for(Task tt:taskList){
            if(tt.Account__c!=null){
                accId.add(tt.Account__c);}
            else if(tt.whatid!=null){
                accId.add(tt.whatid);}
            if(tt.Contact__c!=null){
                conId.add(tt.Contact__c);}
            else if(tt.whoid!=null){
                conId.add(tt.whoid);}
            if(tt.Support__c!=null){
                userId.add(tt.Support__c);
            }
        }
        if(!accId.isEmpty()){
            List<Account> accList=[select Id,Name from Account where Id in :accId];
            for(Account acc:accList){
                accMap.put(acc.Id,acc.Name);
            }            
        }
        if(!conId.isEmpty()){
            List<Contact> conList=[select Id,Name from Contact where Id in :conId]; 
            for(Contact con:conList){
                conMap.put(con.Id,con.Name);
            }
        }
        if(!userId.isEmpty()){
            List<User> userList=[select Id,Email,Name from User where Id in :userId]; 
            for(User us:userList){
                userMap.put(us.Id,us.Email);
            }
        }
        
        for(Task tt:taskList){  
            
            if(tt.Contact__c!=null){
                tt.WhoId=tt.Contact__c;
            }
			else if(tt.whoid!=null){
                tt.Contact__c=tt.whoid;
            }           
            if(tt.Account__c!=null){                
                tt.WhatId=tt.Account__c;
            }
            else if(tt.WhatId!=null){                
                tt.Account__c=tt.WhatId;
            }
            if(tt.Support__c!=null){                
                tt.Support_Email__c=userMap.get(tt.Support__c);
            }
            String conName=conMap.get(tt.Contact__c);
            System.debug('conname'+conName);
            
            if(tt.Contact__c!=null ){ 
                if(tt.Category__c!=null){
                 
                    tt.Subject=tt.Category__c+':'+conName+':'+accMap.get(tt.Account__c);     }
                else{
                    tt.Subject=conName+':'+accMap.get(tt.Account__c);
                }
            }else if(tt.Account__c!=null){
                if(tt.Category__c!=null){
                    
                tt.Subject=tt.Category__c+':'+accMap.get(tt.Account__c); 
                }               else{
                    tt.Subject=accMap.get(tt.Account__c);
                } 
            } else{
                tt.Subject=tt.Category__c;
            }
        } 
    }
    
    public static void onAfterUpdate(List<Task> taskList,Map<Id,Task> oldMap,Map<Id,Task> newMap){
        System.debug('0 Handler');                
        List<Messaging.Email> emails=new List<Messaging.Email>();        
        map<Id,String> userMap=new map<Id,String>();
        set<Id> taskIdset=new set<Id>(); 
        set<Id> userId=new set<Id>();
        
        for(Task ttk:taskList){
            System.debug('1 for');
            if( oldMap.get(ttk.Id).Contact__c!=ttk.Contact__c ||
                oldMap.get(ttk.Id).Account__c!=ttk.Account__c ||
                oldMap.get(ttk.Id).WhoId!=ttk.WhoId ||
                oldMap.get(ttk.Id).WhatId!=ttk.WhatId||
               ttk.Category__c!=null && oldMap.get(ttk.Id).Category__c!=ttk.Category__c){                
                   taskIdset.add(ttk.Id);  
                   System.debug('1');
               }      
            if(oldMap.get(ttk.Id).Support__c!=ttk.Support__c&&ttk.Support__c!=null){
                userId.add(ttk.Support__c);
                taskIdset.add(ttk.Id);
            }
        } 
        if(!userId.isEmpty()){
            List<User> userList=[select Id,Email,Name from User where Id in :userId]; 
            for(User us:userList){
                userMap.put(us.Id,us.Email);
            }
        }
        List<Task> taskUpdateList=[select Id,Category__c,StartDateTime__c ,Owner.FirstName,Owner.Name,Support__r.Name,Support__r.Email,Contact__c,Contact__r.Name,Account__c,Account__r.Name,
                                   Subject,WhoId,Who.Name,WhatId,What.Name 
                                   from Task where Id in :taskIdset];
        System.debug('list'+taskUpdateList);
        
        for(Task tt:taskUpdateList){ 
            String accName;
            String conName;
            if(oldMap.get(tt.Id).Support__c!=tt.Support__c&&tt.Support__c!=null){
              
                tt.Support_Email__c=userMap.get(tt.Support__c);  
            }
            
            
            if( tt.Account__c!=oldMap.get(tt.Id).Account__c){                
                tt.WhatId=newMap.get(tt.Id).Account__c;
                accName=tt.Account__r.Name;
                
            }else  if( tt.WhatId!=oldMap.get(tt.Id).WhatId){                
                tt.Account__c=newMap.get(tt.Id).WhatId;
                accName=tt.What.Name;
                
            }  else{
                accName=tt.What.Name;
            }
            System.debug('email change');
           
            if( tt.Contact__c!=oldMap.get(tt.Id).Contact__c){
                tt.WhoId=newMap.get(tt.Id).Contact__c;
                conName=tt.Contact__r.Name;
                
            }else if( tt.WhoId!=oldMap.get(tt.Id).WhoId){
                tt.Contact__c=newMap.get(tt.Id).WhoId;
                conName=tt.Who.Name;
                
            } else{
                conName=tt.Who.Name;
            }   
            System.debug('Names: acc'+accName+' '+conName); 
            if(conName!=null){
                if(tt.Category__c!=null){
                 
                
                    tt.Subject=tt.Category__c+':'+conName+':'+accName; 
                }else{
                    tt.Subject=conName+':'+accName;
                }
            }else if(accName!=null){
                if(tt.Category__c!=null){
                    
                tt.Subject=tt.Category__c+':'+accName; 
                }               else{
                    tt.Subject=accName;
                } 
            }else{                
            tt.Subject=tt.Category__c;
            }  
            System.debug('before mail');
            
            /*if(oldMap.get(tt.Id).Support__c!=tt.Support__c&&tt.Support__c!=null){
            	System.debug('send mail');
                
                 tt.Support_Email__c=userMap.get(tt.Support__c);                
                Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
                mail.setSubject(tt.Owner.Name+' needs your support in a task');
                mail.setPlainTextBody('Dear '+tt.Support__r.Name+','+'\n'+'\n'
                                      +tt.Owner.Name+' has asked your support in task '+tt.Subject+'. '
                                      +'The task is scheduled on '+tt.StartDateTime__c+'. '+'Please contact '+tt.Owner.FirstName+
                                      +' for more details.'+'\n'+'\n' 
                                      +'Thank You'+'\n'+'\n');
                List<String> param=new List<String>();
                System.debug('to mail'+tt.Support__r.Email);
                
                param.add(tt.Support__r.Email); 
                mail.setToAddresses(param);
                emails.add(mail);                
            }*/
        }
        System.debug('before send list');
        /*if(!emails.isEmpty()){ 
             System.debug('send list mail');
            Messaging.sendEmail(emails);
        }*/
        update taskUpdateList;  
    }
    
    public static void onBeforeDelete(List<Task> taskList ){
        String userProfile=UserInfo.getProfileId();
        Profile prof=[select Id,Name from Profile where Id=:userProfile];
        for(Task tt:taskList){
            if(prof.Name!='System Administrator'){                
            	tt.addError('You do not have access to delete task. Please contact admin.');
                
            }
        }
    }
    
    
}