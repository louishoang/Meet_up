function validateForm(form){
	/* Loop through fields with the class of "req" */
	for (var i = 0; i < form.elements.length; i++) {
        if (form.elements[i].className == "req" && form.elements[i].value.length == 0) {
            alert('Please fill in all required fields');
            return false;
        }
    }
}

