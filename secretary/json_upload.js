document.getElementById('upload-button').addEventListener('click', () => {
    const fileInput = document.getElementById('json-file');
    const uploadMessage = document.getElementById('upload-message');
    const professorsTable = document.getElementById('professors-table').querySelector('tbody');
    const studentsTable = document.getElementById('students-table').querySelector('tbody');

    if (!fileInput.files.length) {
        uploadMessage.textContent = 'Please select a JSON file to upload.';
        uploadMessage.style.color = 'red';
        return;
    }

    const file = fileInput.files[0];
    const reader = new FileReader();

    reader.onload = () => {
        try {
            const jsonData = JSON.parse(reader.result);

            // Clear previous table rows
            professorsTable.innerHTML = '';
            studentsTable.innerHTML = '';

            // Display professors data
            if (jsonData.professors) {
                jsonData.professors.forEach(professor => {
                    const row = document.createElement('tr');
                    row.innerHTML = `
                        <td>${professor.id}</td>
                        <td>${professor.name}</td>
                        <td>${professor.surname}</td>
                        <td>${professor.email}</td>
                        <td>${professor.topic}</td>
                        <td>${professor.landline}</td>
                        <td>${professor.mobile}</td>
                        <td>${professor.department}</td>
                        <td>${professor.university}</td>
                    `;
                    professorsTable.appendChild(row);
                });
            }

            // Display students data
            if (jsonData.students) {
                jsonData.students.forEach(student => {
                    const row = document.createElement('tr');
                    row.innerHTML = `
                        <td>${student.id}</td>
                        <td>${student.name}</td>
                        <td>${student.surname}</td>
                        <td>${student.email}</td>
                        <td>${student.landline}</td>
                        <td>${student.mobile}</td>
                        <td>${student.department}</td>
                        <td>${student.university}</td>
                    `;
                    studentsTable.appendChild(row);
                });
            }

            uploadMessage.textContent = 'File processed successfully!';
            uploadMessage.style.color = 'green';

            // Send data to the backend
            const formData = new FormData();
            formData.append('jsonData', JSON.stringify(jsonData));

            fetch('upload.php', {
                method: 'POST',
                body: formData,
            })
            .then(response => response.text())
            .then(data => {
                console.log(data);
                uploadMessage.textContent = 'Data uploaded to the database successfully!';
                uploadMessage.style.color = 'green';
            })
            .catch(error => {
                console.error('Error uploading data:', error);
                uploadMessage.textContent = 'Error uploading data. Check the console.';
                uploadMessage.style.color = 'red';
            });
        } catch (error) {
            uploadMessage.textContent = 'Error parsing the JSON file. Please ensure it is valid.';
            uploadMessage.style.color = 'red';
        }
    };

    reader.readAsText(file);
});
