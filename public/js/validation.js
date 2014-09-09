function validateForm(){
	/* Loop through fields with the class of "req" */
	for (var i = 0; i < add_meetup.elements.length; i++) {
        if (add_meetup.elements[i].className == "req" && add_meetup.elements[i].value.length == 0) {
            alert('Please fill in all required fields');
            return false;
        }
    }
}

