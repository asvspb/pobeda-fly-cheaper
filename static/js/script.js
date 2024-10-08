document.addEventListener('DOMContentLoaded', function () {
    flatpickr("#start_date", {
        dateFormat: "d.m.Y",
        minDate: "today",
        defaultDate: new Date().fp_incr(1)
    });
    const destinationSelect = document.getElementById('destination');
    for (let i = 0; i < destinationSelect.options.length; i++) {
        if (destinationSelect.options[i].text === 'Москва') {
            destinationSelect.selectedIndex = i;
            break;
        }
    }
    const sortButton = document.getElementById('sortButton');
    sortButton.addEventListener('click', sortResultsByPrice);

    function sortResultsByPrice() {
        const tbody = document.querySelector('#resultsTable tbody');
        const rows = Array.from(tbody.querySelectorAll('tr'));

        rows.sort((a, b) => {
            const priceA = parseFloat(a.cells[1].textContent.replace('₽', '').replace(/\s/g, ''));
            const priceB = parseFloat(b.cells[1].textContent.replace('₽', '').replace(/\s/g, ''));
            return priceA - priceB;
        });

        rows.forEach(row => tbody.appendChild(row));
    }

    document.getElementById('searchForm').addEventListener('submit', function (event) {
        event.preventDefault();

        const formData = new FormData(event.target);

        if (!formData.get('start_date')) {
            const tomorrow = new Date();
            tomorrow.setDate(tomorrow.getDate() + 1);
            formData.set('start_date', tomorrow.toLocaleDateString('ru-RU', { day: '2-digit', month: '2-digit', year: 'numeric' }).replace(/\//g, '.'));
        }

        if (!formData.get('days') || formData.get('days') < 1) {
            formData.set('days', '10');
        }

        document.getElementById('loading').style.display = 'flex';
        document.getElementById('results').style.display = 'none';
        document.querySelector('#resultsTable tbody').innerHTML = '';
        sortButton.style.display = 'none'; // Скрываем кнопку сортировки при начале нового поиска

        const eventSource = new EventSource('/search?' + new URLSearchParams(formData).toString());

        eventSource.onmessage = function (event) {
            const data = JSON.parse(event.data);
            if (data.finished) {
                eventSource.close();
                document.getElementById('loading').style.display = 'none';
                document.getElementById('results').style.display = 'block';
                sortButton.style.display = 'block'; // Показываем кнопку сортировки
            } else if (data.error) {
                addRowToTable(data.date || 'Неизвестная дата', 'Ошибка: ' + data.error, '', '');
            } else {
                addRowToTable(data.date, data.price + '₽', data.departure_time, data.arrival_time);
            }
        };

        eventSource.onerror = function (error) {
            console.error('EventSource failed:', error);
            eventSource.close();
            document.getElementById('loading').style.display = 'none';
            document.getElementById('results').style.display = 'block';
            addRowToTable('Ошибка', 'Произошла ошибка при поиске билетов', '', '');
        };
    });
});

function addRowToTable(date, price, departureTime, arrivalTime) {
    const tbody = document.querySelector('#resultsTable tbody');
    const row = tbody.insertRow();
    row.insertCell(0).textContent = date;
    row.insertCell(1).textContent = price;
    row.insertCell(2).textContent = departureTime;
    row.insertCell(3).textContent = arrivalTime;

    if (price.startsWith('Ошибка')) {
        row.classList.add('error');
    }
}
