// --------- EVENTS FORM FIELDS -----------
var validateEventName = function(alertStatement) {
	var eventName = $('#new-event-form #event_name').val();
	if (eventName === '') {
		return "event's name";
	} else { 
		return "";
	}
}
// --------- CREATOR FORM FIELDS -----------
var validateCreatorName = function(alertStatement) {
	var creatorName = $('#new-event-form #creator_name').val();
	if (creatorName === '' && alertStatement === '') {
		return "creator's name";
	} else if (creatorName === '') {
		return ", creator's name";
	} else { 
		return "";
	}
}
var validateCreatorEmail = function(alertStatement) {
	var creatorEmail = $('#new-event-form #creator_email').val();
	if (creatorEmail === '' && alertStatement === '') {
		return "creator's email";
	} else if (creatorEmail === '') {
		return ", creator's email";
	} else { 
		return "";
	}
}
var validateCreatorPhone = function(alertStatement) {
	var creatorPhone = $('#new-event-form #creator_phone').val();
	if (creatorPhone === '' && alertStatement === '') {
		return "creator's phone";
	} else if (creatorPhone === '') {
		return ", creator's phone";
	} else { 
		return "";
	}
}
// --------- EVENT FORM FIELDS -----------
var validateEventLocation = function(alertStatement) {
	var eventLocation = $('#new-event-form #event_location').val();
	if (eventLocation === '' && alertStatement === '') {
		return "event location";
	} else if (eventLocation === '') {
		return ", event location";
	} else { 
		return "";
	}
}
var validateEventTime = function(alertStatement) {
	var eventTime = $('#new-event-form #event_time').val();
	if (eventTime === '' && alertStatement === '') {
		return "event time";
	} else if (eventTime === '') {
		return ", event time";
	} else { 
		return "";
	}
}
var validateSignupDeadline = function(alertStatement) {
	var signupDeadline = $('#new-event-form #deadline').val();
	if (signupDeadline === '' && alertStatement === '') {
		return "deadline";
	} else if (signupDeadline === '') {
		return ", deadline";
	} else { 
		return "";
	}
}
// --------- EVENT NUMBERS FORM FIELDS -----------
var validateMinimumNumber = function(alertStatement) {
	var minimumNumberAttendees = +$('#new-event-form #minimum_attendees').val();
	if (minimumNumberAttendees === 0 && alertStatement === '') {
		return "minimum number";
	} else if (minimumNumberAttendees === 0) {
		return ", minimum number";
	} else { 
		return "";
	}
}
// --------- EMAILS FORM TEXT FIELDS -----------
var validateInviteeEmails = function(alertStatement) {
	var attendeeEmailAddresses = $('#new-event-form #invitees').val();
	if (attendeeEmailAddresses === '' && alertStatement === '') {
		return "at least 1 attendee email";
	} else if (attendeeEmailAddresses === '') {
		return ", at least 1 attendee email";
	} else { 
		return "";
	}
}



// --------- FINAL FORM FIELDS VALIDATION -----------
var validateAddEventForm = function() {
	var alertStatement = "";

	alertStatement += validateEventName(alertStatement);

	alertStatement += validateCreatorName(alertStatement);
	alertStatement += validateCreatorEmail(alertStatement);
	alertStatement += validateCreatorPhone(alertStatement);

	alertStatement += validateEventLocation(alertStatement);
	alertStatement += validateEventTime(alertStatement);
	alertStatement += validateSignupDeadline(alertStatement);

	alertStatement += validateMinimumNumber(alertStatement);
	alertStatement += validateInviteeEmails(alertStatement);

	return alertStatement;
}


$(document).on('submit','#new-event-form', function(e){
	var alertStatement = validateAddEventForm();
	
	if (alertStatement.length === 0) {
		e.preventDefault();
		$('#new-event-form-response').html('Form is good to go.').show();
		console.log('in the form good to go condition');
	} else {
		e.preventDefault();
		alertStatement = "<p><strong>The following fields cannot be empty: </strong>" + alertStatement + ".</p>";
		$('#new-event-form-response').addClass('form-error').html(alertStatement).show();
		// alert();
		console.log('in the else condition');
	}
	
	return;
});