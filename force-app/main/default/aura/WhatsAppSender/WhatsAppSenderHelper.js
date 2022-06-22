({
    /*sendMessage : function(component, event) {
        var action = component.get("c.sendMessage");
        action.setParams({
            mobileno: component.find("mobileNumber").get("v.value"),
            message: component.find("message").get("v.value")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.find('notifLib').showNotice({
                    "variant": "info",
                    "header": "Success!",
                    "message": "WhatsApp Message Sent"
                });
                
            } else {
                component.find('notifLib').showNotice({
                    "variant": "error",
                    "header": "Something has gone wrong!",
                    "message": "Contact Admin"
                });
            }
        });
        $A.enqueueAction(action);
    },*/
    
    insrtContact : function(component, event, regCont) {
        var action = component.get("c.insertContact");
        action.setParams({
            con: component.get("v.contact"),
            regcontnum: regCont,
            gmId: component.get("v.game").Id
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.game', response.getReturnValue());
                $A.util.addClass(component.find("regContact"), 'slds-hide');
        		$A.util.removeClass(component.find("regContact"), 'slds-show');
            } else {
                $A.util.addClass(component.find("regContact"), 'slds-hide');
        		$A.util.removeClass(component.find("regContact"), 'slds-show');
                component.find('notifLib').showNotice({
                    "variant": "error",
                    "header": "Something has gone wrong!",
                    "message": "Contact Admin"
                });
            }
        });
        $A.enqueueAction(action);
    },
    
    updateGame : function(component, event) {
        var action = component.get("c.updateGame");
        action.setParams({
            game: component.get("v.game")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.find('notifLib').showNotice({
                    "variant": "info",
                    "header": "Thank you All!",
                    "message": "Congratulations to the Winner"
                });
            } else {
                $A.util.addClass(component.find("regContact"), 'slds-hide');
        		$A.util.removeClass(component.find("regContact"), 'slds-show');
                component.find('notifLib').showNotice({
                    "variant": "error",
                    "header": "Something has gone wrong!",
                    "message": "Contact Admin"
                });
            }
        });
        $A.enqueueAction(action);
    },

    getGame : function(component, event) {
        var action = component.get("c.insertNewGame");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.game', response.getReturnValue());
            } else {
                component.find('notifLib').showNotice({
                    "variant": "error",
                    "header": "Something has gone wrong!",
                    "message": "Contact Admin"
                });
            }
        });
        $A.enqueueAction(action);
    },

    addPartic : function(component, event) {
        var action = component.get("c.addParticipants");
        action.setParams({
            game: component.get("v.game")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {  
                var res = response.getReturnValue();
                component.set('v.game', res.gamechk);
                if(res.gamechk.Participant_1__c == undefined && res.unRegP1Phone != '') {component.set("v.unregp1", res.unRegP1Phone);}
                if(res.gamechk.Participant_2__c == undefined && res.unRegP2Phone != '') {component.set("v.unregp2", res.unRegP2Phone);}
                if(res.gamechk.Participant_3__c == undefined && res.unRegP3Phone != '') {component.set("v.unregp3", res.unRegP3Phone);}
                if(res.gamechk.Participant_4__c == undefined && res.unRegP4Phone != '') {component.set("v.unregp4", res.unRegP4Phone);}
                
                if(res.gamechk.Participant_1__c == undefined && res.unRegP1Phone == undefined){
                    $A.util.addClass(component.find("regbt1"), 'slds-hide');
                    $A.util.removeClass(component.find("regbt1"), 'slds-show');
                } 
                if(res.gamechk.Participant_2__c == undefined && res.unRegP2Phone == undefined){
                    $A.util.addClass(component.find("regbt2"), 'slds-hide');
                    $A.util.removeClass(component.find("regbt2"), 'slds-show');
                } 
                if(res.gamechk.Participant_3__c == undefined && res.unRegP3Phone == undefined){
                    $A.util.addClass(component.find("regbt3"), 'slds-hide');
                    $A.util.removeClass(component.find("regbt3"), 'slds-show');
                } 
                if(res.gamechk.Participant_4__c == undefined && res.unRegP4Phone == undefined){
                    $A.util.addClass(component.find("regbt4"), 'slds-hide');
                    $A.util.removeClass(component.find("regbt4"), 'slds-show');
                } 
            } else {
                component.find('notifLib').showNotice({
                    "variant": "error",
                    "header": "Something has gone wrong!",
                    "message": "Contact Admin"
                });
            }
            this.refGame(component, event);
        });
        $A.enqueueAction(action);
    },
    
    refGame : function(component, event) {
        var action = component.get("c.refGame");
        action.setParams({
            gmId: component.get("v.game").Id
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var res = response.getReturnValue();
                component.set('v.game', res);        
            } else {
                component.find('notifLib').showNotice({
                    "variant": "error",
                    "header": "Something has gone wrong!",
                    "message": "Contact Admin"
                });
            }
        });
        $A.enqueueAction(action);
    },
    
    getMessage : function(component, event) {
        component.set('v.rightAnsBy', '');
        component.set('v.rightAnsIn', 0);
        let but2 = component.find('chkbut');
    	but2.set('v.disabled',true);
        let but = component.find('nxtbut');
    	but.set('v.disabled',false);
        var action = component.get("c.getMessage");
        action.setParams({
            crctans: component.get("v.crctAnswer"),
            qstsrtTime: component.get("v.qstStartTime")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {  
                var res = response.getReturnValue();
                console.log('Correct Answer Given By:' + JSON.stringify(res));
                var game = component.get("v.game");
                
                if(res != null && res != '' && res != undefined){
                    if(game.Participant_1__r.Phone === res.winPhone){
                        var curscr = component.get("v.p1Score");
                        curscr = curscr + 1;
                        component.set('v.p1Score', curscr);
                        component.set('v.rightAnsBy', game.Participant_1__r.Name);
                        component.set('v.rightAnsIn', res.winSeconds);
                    }else if(game.Participant_2__r.Phone === res.winPhone){
                        var curscr = component.get("v.p2Score");
                        curscr = curscr + 1;
                        component.set('v.p2Score', curscr);
                        component.set('v.rightAnsBy', game.Participant_2__r.Name);
                        component.set('v.rightAnsIn', res.winSeconds);
                    }else if(game.Participant_3__r.Phone === res.winPhone){
                        var curscr = component.get("v.p3Score");
                        curscr = curscr + 1;
                        component.set('v.p3Score', curscr);
                        component.set('v.rightAnsBy', game.Participant_3__r.Name);
                        component.set('v.rightAnsIn', res.winSeconds);
                    }else if(game.Participant_4__r.Phone === res.winPhone){
                        var curscr = component.get("v.p4Score");
                        curscr = curscr + 1;
                        component.set('v.p4Score', curscr);
                        component.set('v.rightAnsBy', game.Participant_4__r.Name);
                        component.set('v.rightAnsIn', res.winSeconds);
                    }
                }else{
                    component.set("v.rightAnsBy", '');
                    component.set("v.rightAnsIn", 0);
                } 
                
                var nost = component.get("v.rightAnsBy");
                var mist = component.get("v.rightAnsIn");
                
                if(nost != null && nost != undefined && mist != 0 && mist != undefined ){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Well Done!!',
                        message: 'Right answer given by '+ nost +'. Time taken to answer - '+ mist +' seconds.',
                        duration: '3000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                } else if(nost === '' && mist === 0){
                    var toastEvent1 = $A.get("e.force:showToast");
                    toastEvent1.setParams({
                        title : 'Damn!!',
                        message: 'No one gave the right answer',
                        duration: '3000',
                        key: 'info_alt',
                        type: 'info',
                        mode: 'dismissible'
                    });
                    toastEvent1.fire();
                }
                
            } else {
                component.find('notifLib').showNotice({
                    "variant": "error",
                    "header": "Something has gone wrong!",
                    "message": "Contact Admin"
                });
            }
        });
        $A.enqueueAction(action);
    },

    getQuest : function(component, event) {
        var action = component.get("c.getQuest");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {  
                var num = $A.get("$Label.c.Number_of_questions");
                console.log('Total Questions:' + num);
                component.set('v.numofquest', num);
                var res = response.getReturnValue();
                console.log('Question List:' + JSON.stringify(res));
                component.set('v.questions', res);
                component.set('v.crctAnswer', res[0].Answer__c);
                component.set('v.selquest', res[0]);
                var today = new Date();
                var utdtTim = $A.localizationService.formatDateTimeUTC(today);
                component.set('v.qstStartTime', utdtTim);
                console.log('Question Start Time:' + component.get('v.qstStartTime'));
                console.log('Right Answer:' + component.get('v.crctAnswer'));
                let but = component.find('nxtbut');
    			but.set('v.disabled',true);
            } else {
                component.find('notifLib').showNotice({
                    "variant": "error",
                    "header": "Something has gone wrong!",
                    "message": "Contact Admin"
                });
            }
        });
        $A.enqueueAction(action);
    }
})