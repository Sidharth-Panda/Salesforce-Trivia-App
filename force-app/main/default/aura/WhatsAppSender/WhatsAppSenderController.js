({
	/*handleSendMsg : function(component, event, helper) {
		helper.sendMessage(component, event);
	},*/
    handleAddPart : function(component, event, helper) {
        $A.util.addClass(component.find("showGameId"), 'slds-hide');
        $A.util.removeClass(component.find("showGameId"), 'slds-show');
        
        $A.util.addClass(component.find("showPartcipants"), 'slds-show');
        $A.util.removeClass(component.find("showPartcipants"), 'slds-hide');
		helper.addPartic(component, event);
	},
	handlegetGame : function(component, event, helper) {
        $A.util.addClass(component.find("showInstruction"), 'slds-hide');
        $A.util.removeClass(component.find("showInstruction"), 'slds-show');
        
        $A.util.addClass(component.find("showGameId"), 'slds-show');
        $A.util.removeClass(component.find("showGameId"), 'slds-hide');
        
		helper.getGame(component, event);
	},
    handleshowInstructions : function(component, event, helper) {
		$A.util.removeClass(component.find("showInstruction"), 'slds-hide');
        $A.util.addClass(component.find("showInstruction"), 'slds-show');
        
        $A.util.addClass(component.find("showInitialButton"), 'slds-hide');
        $A.util.removeClass(component.find("showInitialButton"), 'slds-show');
	},
	handleGetQuest : function(component, event, helper) {
		$A.util.removeClass(component.find("showquestion"), 'slds-hide');
        $A.util.addClass(component.find("showquestion"), 'slds-show');
        
        $A.util.addClass(component.find("readybutton"), 'slds-hide');
        
        $A.util.addClass(component.find("showInitialButton"), 'slds-hide');
        $A.util.removeClass(component.find("showInitialButton"), 'slds-show');

		helper.getQuest(component, event);
	},
	chkansw : function(component, event, helper) {
		helper.getMessage(component, event);
	},
    submitContact : function(component, event, helper) {
		var regCont = component.get("v.regCon");
        helper.insrtContact(component, event, regCont);
	},
    handleRegCon1 : function(component, event, helper) {
        component.set('v.contact.FirstName', '');
        component.set('v.contact.LastName', '');
        component.set('v.contact.Email', '');
        $A.util.removeClass(component.find("regContact"), 'slds-hide');
        $A.util.addClass(component.find("regContact"), 'slds-show');
        component.set("v.contact.Phone", component.get("v.unregp1"));
		component.set("v.regCon", 'p1');
	},
    handleRegCon2 : function(component, event, helper) {
        component.set('v.contact.FirstName', '');
        component.set('v.contact.LastName', '');
        component.set('v.contact.Email', '');
        $A.util.removeClass(component.find("regContact"), 'slds-hide');
        $A.util.addClass(component.find("regContact"), 'slds-show');
        component.set("v.contact.Phone", component.get("v.unregp2"));
		component.set("v.regCon", 'p2');
	},
    handleRegCon3 : function(component, event, helper) {
        component.set('v.contact.FirstName', '');
        component.set('v.contact.LastName', '');
        component.set('v.contact.Email', '');
        $A.util.removeClass(component.find("regContact"), 'slds-hide');
        $A.util.addClass(component.find("regContact"), 'slds-show');
        component.set("v.contact.Phone", component.get("v.unregp3"));
		component.set("v.regCon", 'p3');
	},
    handleRegCon4 : function(component, event, helper) {
        component.set('v.contact.FirstName', '');
        component.set('v.contact.LastName', '');
        component.set('v.contact.Email', '');
        $A.util.removeClass(component.find("regContact"), 'slds-hide');
        $A.util.addClass(component.find("regContact"), 'slds-show');
        component.set("v.contact.Phone", component.get("v.unregp4"));
		component.set("v.regCon", 'p4');
	},
    handleshowWinner : function(component, event, helper) {
		$A.util.removeClass(component.find("showWinner"), 'slds-hide');
        $A.util.addClass(component.find("showWinner"), 'slds-show');
        $A.util.addClass(component.find("showquestion"), 'slds-hide');
        $A.util.removeClass(component.find("showquestion"), 'slds-show');
        
        var sc1 = component.get("v.p1Score");
        component.set("v.game.Participant_1_Points__c", sc1);
        var sc2 = component.get("v.p2Score");
        component.set("v.game.Participant_2_Points__c", sc2);
        var sc3 = component.get("v.p3Score");
        component.set("v.game.Participant_3_Points__c", sc3);
        var sc4 = component.get("v.p4Score");
        component.set("v.game.Participant_4_Points__c", sc4);
        var max = Math.max(sc1, sc2, sc3, sc4);
        
        if(max===sc1){
            var qst = component.get("v.game.Participant_1__r.Name");
            component.set("v.winner", qst);
            var win = component.get("v.game.Participant_1__c");
            component.set("v.game.Winner__c", win);
        }else if(max===sc2){
            var qst = component.get("v.game.Participant_2__r.Name");
            component.set("v.winner", qst);
            var win = component.get("v.game.Participant_2__c");
            component.set("v.game.Winner__c", win);
        }else if(max===sc3){
            var qst = component.get("v.game.Participant_3__r.Name");
            component.set("v.winner", qst);
            var win = component.get("v.game.Participant_3__c");
            component.set("v.game.Winner__c", win);
        }else if(max===sc4){
            var qst = component.get("v.game.Participant_4__r.Name");
            component.set("v.winner", qst);
            var win = component.get("v.game.Participant_4__c");
            component.set("v.game.Winner__c", win);
        }
        helper.updateGame(component, event);
	},
	handleNextQuest : function(component, event, helper) {
        let but2 = component.find('chkbut');
    	but2.set('v.disabled',false);
		var iters = component.get("v.iter");
		var totquest = component.get("v.numofquest");
        var today = new Date();
        var utdtTim = $A.localizationService.formatDateTimeUTC(today);
        component.set('v.qstStartTime', utdtTim);
        console.log('Question Start Time:' + component.get('v.qstStartTime'));
		if(totquest-iters>1){
            iters++;
            component.set("v.iter", iters);
            var nxtquest = component.get("v.questions")[iters];
            component.set("v.selquest", nxtquest);
            component.set("v.crctAnswer", nxtquest.Answer__c);
            console.log('Right Answer:' + component.get('v.crctAnswer'));
            let but1 = component.find('nxtbut');
    		but1.set('v.disabled',true);
        }else{
            $A.util.addClass(component.find("questionr"), 'slds-hide');
            let button0 = component.find('chkbut');
    		button0.set('v.disabled',true);
            let button1 = component.find('nxtbut');
    		button1.set('v.disabled',true);
            let button2 = component.find('finishbut');
    		button2.set('v.disabled',false);
            $A.util.addClass(component.find("showPartcipants"), 'slds-hide');
        }
        
	}
})