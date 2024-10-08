from datetime import datetime, timedelta
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time
import traceback
from config import cities

def get_cheapest_tickets(origin, destination, start_date_input, days):
    chrome_options = Options()
    chrome_options.add_argument("--headless")
    chrome_options.add_argument("--disable-gpu")
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--disable-dev-shm-usage")

    driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=chrome_options)

    start_date = datetime.strptime(start_date_input, '%d.%m.%Y')

    for i in range(days):
        current_date = start_date + timedelta(days=i)
        formatted_date = current_date.strftime('%d.%m.%Y')

        url = f"https://ticket.flypobeda.ru/websky/?origin-city-code[0]={origin}&destination-city-code[0]={destination}&date[0]={formatted_date}&segmentsCount=1&adultsCount=1&youngAdultsCount=0&childrenCount=0&infantsWithSeatCount=0&infantsWithoutSeatCount=0&lang=ru#/search"

        try:
            driver.get(url)
            WebDriverWait(driver, 30).until(
                EC.presence_of_element_located((By.CLASS_NAME, 'price-cell__text'))
            )

            price_elements = driver.find_elements(By.CLASS_NAME, 'price-cell__text')
            prices = [float(price.text.replace('₽', '').replace(' ', '').replace('\xa0', '')) for price in price_elements if price.text]

            if prices:
                min_price = min(prices)
                min_price_index = prices.index(min_price)

                flight_info_element = driver.find_elements(By.CLASS_NAME, 'contentRow')[min_price_index]
                time_element = flight_info_element.find_element(By.CLASS_NAME, 'time')
                departure_time, arrival_time = time_element.text.split(' – ')

                yield {
                    'date': formatted_date,
                    'price': min_price,
                    'departure_time': departure_time,
                    'arrival_time': arrival_time
                }
            else:
                yield {
                    'date': formatted_date,
                    'error': 'Билеты не найдены'
                }

        except Exception as e:
            print(f"Не удалось получить данные на {formatted_date}.")
            print(traceback.format_exc())
            yield {
                'date': formatted_date,
                'error': 'Ошибка при поиске'
            }

        time.sleep(1)

    driver.quit()
