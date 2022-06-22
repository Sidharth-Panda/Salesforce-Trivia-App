public class TwilioAPISendInterface {

    /*@AuraEnabled
    public static boolean sendMessage(string mobileno,string message){
        
        errorResponseWrapper erw;
        
        String account = 'ACa3b1781aa75a9bd210ad9787ab7246fb';  
        String token   = '15df8b0e3b5e99649378d477f7c9caf6';
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.twilio.com/2010-04-01/Accounts/'+account+'/Messages.json');
        req.setMethod('POST'); 
        req.setHeader('Content-Type','application/json');
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        
        Blob headerValue = Blob.valueOf(account + ':' + token);
        String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        
        
        if(mobileno != null){
            string jsonString='From='+EncodingUtil.urlEncode('whatsapp:+14155238886', 'UTF-8')+'&Body='+EncodingUtil.urlEncode(message, 'UTF-8')+'&To='+EncodingUtil.urlEncode('whatsapp:'+mobileno+'', 'UTF-8')+'';
            req.setBody(jsonString);
            try{
                Http http = new Http();
                HTTPResponse res = http.send(req);
                System.debug(res.getBody());
                
                if(res.getStatusCode()==201)
                    return true;
                else{
                    system.debug('Twilio failed'+mobileno);
                    erw =(errorResponseWrapper)json.deserialize(res.getBody(),errorResponseWrapper.class);
                    system.debug('Twilio error'+erw.message);
                }
            }
            catch(Exception e){
                system.debug('Error :'+e);
            } 
        }
        return false;
    }*/
    
    @AuraEnabled
    public static WinnerWrapper getMessage(String crctans, String qstsrtTime){
        
        System.debug('Inside getMessage Method');
        System.debug('Correct Answer:' +crctans);
		System.debug('Question Popup time:' +qstsrtTime);
        
        String qstyear = qstsrtTime.substring(7,11);
        String qstmonth = '06';
        String qstdate = qstsrtTime.substring(0,2);
        String qsthour = qstsrtTime.substringAfter(' ').substringBefore(':');
        String qstminute = qstsrtTime.substringAfter(':').substringBefore(':');
        String qstsecond = qstsrtTime.substringAfterLast(':').substringBefore(' ');
        String amorpm = qstsrtTime.substringAfterLast(' ');
        if(amorpm == 'pm'){
            Integer intu = Integer.valueOf(qsthour);
            intu = intu + 12;
            qsthour = String.valueOf(intu);
        }
        DateTime qststdt = DateTime.newInstanceGMT(Integer.valueof(qstyear), Integer.valueof(qstmonth), Integer.valueof(qstdate), Integer.valueof(qsthour), Integer.valueof(qstminute), Integer.valueof(qstsecond));
        
        ResponseGetWrapper response;
        WinnerWrapper winWrap;
        datetime curDateTime = datetime.now();
        Long qstTime = qststdt.getTime();
        datetime lastAPICall;
        Map<String, Integer> phnSecMap = new Map<String, Integer>();
        Integer shrtSec = 0;
        String strpho = '';

        List<Datetime_of_Last_Retrieved_Message__mdt> metaList = [Select MasterLabel, DeveloperName, Last_DateTime_Msg_retrived__c 
                                                                From Datetime_of_Last_Retrieved_Message__mdt];
       
        if(!metaList.isEmpty()){
            lastAPICall = metaList[0].Last_DateTime_Msg_retrived__c;
        }

        String account = 'ACa3b1781aa75a9bd210ad9787ab7246fb';  
        String token   = '15df8b0e3b5e99649378d477f7c9caf6';
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.twilio.com/2010-04-01/Accounts/'+account+'/Messages.json');
        req.setMethod('GET'); 
        req.setHeader('Content-Type','application/json');
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        
        Blob headerValue = Blob.valueOf(account + ':' + token);
        String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        try{
            Http http = new Http();
            HTTPResponse res = http.send(req);
            string responseBody = res.getBody().replace('from','froms');
            response = (ResponseGetWrapper)json.deserialize(responseBody,ResponseGetWrapper.class);
            System.debug('Twilio Message:' +response);
            List<Message> msg = new List<Message>();
            List<string> mobile = new List<string>();
            
            for(Message wrp:response.messages){

                String msgyear = wrp.date_updated.substring(12,16);
                String msgmonth = '06';
                String msgdate = wrp.date_updated.substringBetween(' ',' ');
                String msghour = wrp.date_updated.substring(17,19);
                String msgminute = wrp.date_updated.substringBetween(':',':');
                String msgsecond = wrp.date_updated.substring(23,25);
                DateTime mgsdt = DateTime.newInstanceGMT(Integer.valueof(msgyear), Integer.valueof(msgmonth), Integer.valueof(msgdate), Integer.valueof(msghour), Integer.valueof(msgminute), Integer.valueof(msgsecond));
                Long ansTime = mgsdt.getTime();
                Long milliseconds = ansTime - qstTime;
                Integer seconds = Integer.Valueof(milliseconds / 1000);

                if(!mobile.contains(wrp.froms.substringAfter('+')) && wrp.body != null && wrp.body == crctans && wrp.direction != null && wrp.direction == 'inbound' && mgsdt > lastAPICall){
                    string phn = '+' + wrp.froms.substringAfter('+');
                    phnSecMap.put(phn,seconds);
                    strpho = phn;
                    shrtSec = seconds;
                }

                mobile.add(wrp.froms.substringAfter('+'));
            }

            System.debug('Incoming Messages:' +phnSecMap);

            if(!phnSecMap.isEmpty()){

                //instance of the record
                Metadata.CustomMetadata mdata = new Metadata.CustomMetadata();
                mdata.fullName = 'Datetime_of_Last_Retrieved_Message__mdt.'+'NewDeveloperName';
                mdata.label = 'RecLabel';
                //instance of the value
                Metadata.CustomMetadataValue instance = new Metadata.CustomMetadataValue();
                instance.field = 'Last_DateTime_Msg_retrived__c';
                instance.value = curDateTime;
                //adding the value to the record
                mdata.values.add(instance);
                //instance of the container
                Metadata.DeployContainer container = new Metadata.DeployContainer();
                container.addMetadata(mdata);
                //enqueue deployment to the salesforce org
                Metadata.Operations.enqueueDeployment(container, null);
                winWrap = new WinnerWrapper();
                winWrap.winPhone = strpho;
                winWrap.winSeconds = shrtSec;

                for(String phn:phnSecMap.keyset()){
                    if(phnSecMap.get(phn) < shrtSec){
                        winWrap = new WinnerWrapper() ;
                        shrtSec = phnSecMap.get(phn);
                        winWrap.winPhone = phn;
                        winWrap.winSeconds = phnSecMap.get(phn);
                    }

                }
                system.debug('Right answer given by: ' +winWrap);
                return winWrap;    
            }
            return null;
        }
        catch(Exception e){
            system.debug('Error :'+e);
        }
        return null;
    }

    @AuraEnabled
    public static PartWrapper addParticipants(Game__c game){

        Game__c myGame = [SELECT Id, Name, Participant_1__c, Participant_2__c, Participant_3__c, Participant_4__c,
                            Winner__c, Participant_1__r.Name, Participant_2__r.Name, Participant_3__r.Name, Participant_4__r.Name,
                            Participant_1__r.Phone, Participant_2__r.Phone, Participant_3__r.Phone, Participant_4__r.Phone 
                          FROM Game__c where Id=:game.Id];
        
        ResponseGetWrapper response;
        PartWrapper prtwrp = new PartWrapper();
        datetime curDateTime = datetime.now();
        datetime lastAPICall;

        List<Datetime_of_Last_Retrieved_Message__mdt> metaList = [Select MasterLabel, DeveloperName, Last_DateTime_Msg_retrived__c 
                                                                From Datetime_of_Last_Retrieved_Message__mdt];
       
        if(!metaList.isEmpty()){
            lastAPICall = metaList[0].Last_DateTime_Msg_retrived__c;
        }

        String account = 'ACa3b1781aa75a9bd210ad9787ab7246fb';  
        String token   = '15df8b0e3b5e99649378d477f7c9caf6';
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.twilio.com/2010-04-01/Accounts/'+account+'/Messages.json');
        req.setMethod('GET'); 
        req.setHeader('Content-Type','application/json');
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        
        Blob headerValue = Blob.valueOf(account + ':' + token);
        String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        try{
            Http http = new Http();
            HTTPResponse res = http.send(req);
            string responseBody = res.getBody().replace('from','froms');
            response = (ResponseGetWrapper)json.deserialize(responseBody,ResponseGetWrapper.class);
            System.debug('Twilio Message:' +response);
            list<string> msg = new list<string>();
            set<string> msgset = new set<string>();
            for(Message wrp:response.messages){
                String msgyear = wrp.date_updated.substring(12,16);
                String msgmonth = '06';
                String msgdate = wrp.date_updated.substringBetween(' ',' ');
                String msghour = wrp.date_updated.substring(17,19);
                String msgminute = wrp.date_updated.substringBetween(':',':');
                String msgsecond = wrp.date_updated.substring(23,25);
                DateTime mgsdt = DateTime.newInstanceGMT(Integer.valueof(msgyear), Integer.valueof(msgmonth), Integer.valueof(msgdate), Integer.valueof(msghour), Integer.valueof(msgminute), Integer.valueof(msgsecond));
                if(wrp.body != null && wrp.body == myGame.Name && wrp.direction != null && wrp.direction == 'inbound' && mgsdt > lastAPICall){
                    string phn = '+' + wrp.froms.substringAfter('+');
                    msg.add(phn);
                }
            }
            msgset.addAll(msg);
            msg.clear();
            msg.addAll(msgset);
            Map<String,Id> phoneToContactId = new Map<String,Id>();
            System.debug('Phone Numbers :' +msg);
            if(!msg.isEmpty()){
                //instance of the record
                Metadata.CustomMetadata mdata = new Metadata.CustomMetadata();
                mdata.fullName = 'Datetime_of_Last_Retrieved_Message__mdt.'+'NewDeveloperName';
                mdata.label = 'RecLabel';
                //instance of the value
                Metadata.CustomMetadataValue instance = new Metadata.CustomMetadataValue();
                instance.field = 'Last_DateTime_Msg_retrived__c';
                instance.value = curDateTime;
                //adding the value to the record
                mdata.values.add(instance);
                //instance of the container
                Metadata.DeployContainer container = new Metadata.DeployContainer();
                container.addMetadata(mdata);
                //enqueue deployment to the salesforce org
                Metadata.Operations.enqueueDeployment(container, null);
            }
            List<Contact> myCon = [select Id, Phone from contact where IsBlacklistedFromGames__c = false AND Phone IN :msg];
            for(Contact con:myCon){
                String ph = String.valueof(con.Phone);
                if(msg.contains(ph)){
                    phoneToContactId.put(ph, con.Id);
                    Integer result = msg.indexOf(ph);
                    msg.remove(result);
                }
            }
            Integer matchContactCount  = phoneToContactId.size();
            List<Id> idVals = phoneToContactId.values();
            System.debug('Unregistered Phone Numbers :' +msg);
            System.debug('Matched Contact Ids :' +idVals);

            if(matchContactCount==0){
                if(msg.size()>=1) prtwrp.unRegP1Phone = msg[0];
                if(msg.size()>=2) prtwrp.unRegP2Phone = msg[1];
                if(msg.size()>=3) prtwrp.unRegP3Phone = msg[2];
                if(msg.size()>=4) prtwrp.unRegP4Phone = msg[3];
            }
            if(matchContactCount==1){
                myGame.Participant_1__c = idVals[0];
                if(msg.size()>=1) prtwrp.unRegP2Phone = msg[0];
                if(msg.size()>=2) prtwrp.unRegP3Phone = msg[1];
                if(msg.size()>=3) prtwrp.unRegP4Phone = msg[2];
            }
            if(matchContactCount==2){
                myGame.Participant_1__c = idVals[0];
                myGame.Participant_2__c = idVals[1];
                if(msg.size()>=1) prtwrp.unRegP3Phone = msg[0];
                if(msg.size()>=2) prtwrp.unRegP4Phone = msg[1];
            }
            if(matchContactCount==3){
                myGame.Participant_1__c = idVals[0];
                myGame.Participant_2__c = idVals[1];
                myGame.Participant_3__c = idVals[2];
                if(msg.size()>=1) prtwrp.unRegP4Phone = msg[0];
            }
            if(matchContactCount==4){
                myGame.Participant_1__c = idVals[0];
                myGame.Participant_2__c = idVals[1];
                myGame.Participant_3__c = idVals[2];
                myGame.Participant_4__c = idVals[3];
            }
            
            updateGameAsync(myGame.Id, myGame.Participant_1__c, myGame.Participant_2__c, myGame.Participant_3__c, myGame.Participant_4__c );

            prtwrp.gamechk = myGame;

			return prtwrp;
        }
        catch(Exception e){
            system.debug('Error :'+e);
        }
        return null;
    }

    @AuraEnabled
    public static Game__c insertNewGame(){
        Game__c newGame = new Game__c();
        insert newGame;
        Game__c myGame = [SELECT Id, Name, Participant_1__c, Participant_2__c, Participant_3__c, Participant_4__c,
                         Participant_1_Points__c, Participant_2_Points__c, Participant_3_Points__c, Participant_4_Points__c,
                         Winner__c, Participant_1__r.Name, Participant_2__r.Name, Participant_3__r.Name, Participant_4__r.Name,
                         Participant_1__r.Phone, Participant_2__r.Phone, Participant_3__r.Phone, Participant_4__r.Phone 
                         FROM Game__c where Id = :newGame.Id];
        return myGame;
    }
    
    @AuraEnabled
    public static Game__c refGame(Id gmId){
        Game__c myGame = [SELECT Id, Name, Participant_1__c, Participant_2__c, Participant_3__c, Participant_4__c,
                         Participant_1_Points__c, Participant_2_Points__c, Participant_3_Points__c, Participant_4_Points__c,
                         Winner__c, Participant_1__r.Name, Participant_2__r.Name, Participant_3__r.Name, Participant_4__r.Name,
                         Participant_1__r.Phone, Participant_2__r.Phone, Participant_3__r.Phone, Participant_4__r.Phone 
                         FROM Game__c where Id = :gmId];
        return myGame;
    }
    
    @AuraEnabled
    public static boolean updateGame(Game__c game){
        Game__c myGame =  game;
        update myGame;
        Game__c gmsr = [SELECT Id, Name, Participant_1__c, Participant_2__c, Participant_3__c, Participant_4__c,
                         Participant_1_Points__c, Participant_2_Points__c, Participant_3_Points__c, Participant_4_Points__c,
                         Winner__c, Participant_1__r.Name, Participant_2__r.Name, Participant_3__r.Name, Participant_4__r.Name,
                         Participant_1__r.Phone, Participant_2__r.Phone, Participant_3__r.Phone, Participant_4__r.Phone, Winner__r.Email 
                         FROM Game__c where Id=:myGame.Id];
        if(gmsr.Winner__r.Email != null){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {gmsr.Winner__r.Email}; 
            mail.setToAddresses(toAddresses);
            mail.setReplyTo('support@salesforce.com');
            mail.setSenderDisplayName('Salesforce Support');
            mail.setSubject('Winner of the Game : ' + gmsr.Name);
            mail.setBccSender(false);
            mail.setUseSignature(false);
            mail.setPlainTextBody('You won the Game: ' + gmsr.Name +' Congratulations!!!');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        
        updateContactAsync(gmsr.Participant_1__c, gmsr.Participant_2__c, gmsr.Participant_3__c, gmsr.Participant_4__c, gmsr.Winner__c);
        return true;
    }
    
    @AuraEnabled
    public static Game__c insertContact(Contact con, String regcontnum, Id gmId){
        Contact myCon = con;
        insert myCon;
        Id conId = myCon.Id;
        Game__c myGame = [SELECT Id, Participant_1__c, Participant_2__c, Participant_3__c, Participant_4__c FROM Game__c where Id=:gmId];
        if(regcontnum == 'p1') {myGame.Participant_1__c = conId;}
        if(regcontnum == 'p2') {myGame.Participant_2__c = conId;}
        if(regcontnum == 'p3') {myGame.Participant_3__c = conId;}
        if(regcontnum == 'p4') {myGame.Participant_4__c = conId;}
        update myGame;
        Game__c updtGm = [SELECT Id, Name, Participant_1__c, Participant_2__c, Participant_3__c, Participant_4__c,
                         Participant_1_Points__c, Participant_2_Points__c, Participant_3_Points__c, Participant_4_Points__c,
                         Winner__c, Participant_1__r.Name, Participant_2__r.Name, Participant_3__r.Name, Participant_4__r.Name,
                         Participant_1__r.Phone, Participant_2__r.Phone, Participant_3__r.Phone, Participant_4__r.Phone 
                         FROM Game__c where Id=:gmId];
        system.debug('Game: '+updtGm);
        return updtGm;
    }

    @AuraEnabled
    public static List<Question__c> getQuest(){
        integer totQuest = Integer.valueof(Label.Number_of_questions);
        List<Question__c> quest = [SELECT Id, Name, Question__c, Answer__c FROM Question__c LIMIT :totQuest];
        return quest;
    }

    public class ResponseGetWrapper{
        @AuraEnabled
        public List<Message> messages;  
    }
    public class Message{
        @AuraEnabled
        public String body; 
        @AuraEnabled
        public String direction; 
        @AuraEnabled
        public String froms;
        @AuraEnabled
        public String date_updated;
    }
    public class PartWrapper{
        @AuraEnabled
        public Game__c gamechk; 
        @AuraEnabled
        public String unRegP1Phone; 
        @AuraEnabled
        public String unRegP2Phone;
        @AuraEnabled
        public String unRegP3Phone;
        @AuraEnabled
        public String unRegP4Phone;
    }
    public class WinnerWrapper{
        @AuraEnabled
        public String winPhone; 
        @AuraEnabled
        public Integer winSeconds;
    }
    public class errorResponseWrapper{
        @AuraEnabled
        public String code;
        @AuraEnabled
        public String message;
        @AuraEnabled
        public String moreInfo;
        @AuraEnabled
        public String status;    
    }
    @future
	public static void updateGameAsync(Id gmId, Id con1Id, Id con2Id, Id con3Id, Id con4Id){
        Game__c mygm = [SELECT Id, Name, Participant_1__c, Participant_2__c, Participant_3__c, Participant_4__c FROM Game__c where Id=:gmId];
        if(con1Id != null) {mygm.Participant_1__c = con1Id; }
        if(con2Id != null) {mygm.Participant_2__c = con2Id; }
        if(con3Id != null) {mygm.Participant_3__c = con3Id; }
        if(con4Id != null) {mygm.Participant_4__c = con4Id; }
        update mygm;
    }
    @future
	public static void updateContactAsync(Id con1Id, Id con2Id, Id con3Id, Id con4Id, Id winConId){
        Set<Id> conIds = new Set<Id>();
        List<Contact> updtCon = new List<Contact>();
        if(con1Id != null) {conIds.add(con1Id); }
        if(con2Id != null) {conIds.add(con2Id); }
        if(con3Id != null) {conIds.add(con3Id); }
        if(con4Id != null) {conIds.add(con4Id); }
        List<Contact> conLst = [SELECT Id, Number_of_Games_Played__c, Number_of_times_Winner__c FROM Contact WHERE ID IN :conIds];
        for(Contact con:conLst){
            con.Number_of_Games_Played__c = con.Number_of_Games_Played__c + 1;
            if(winConId != null && con.Id == winConId){
                con.Number_of_times_Winner__c = con.Number_of_times_Winner__c + 1;
            }
            updtCon.add(con);
        }
        update updtCon;
    }
}