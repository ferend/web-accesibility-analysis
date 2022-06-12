# Web Accessibility Analysis

The Internet has become an indispensable usage tool of this age we live in. Now we can see it as one of the basic needs that everyone needs in the world. The Internet is becoming an increasingly important resource in many aspects of life, including education, work, government, commerce, health care, leisure, and others. The Web must be accessible to provide people of varying abilities with equal access and opportunity.



With the help of the developed software tool with Python programming language, I used the R programming language for data visualization and other analytic models. 
You can access to the software from the following link:

https://github.com/bertacsevercan/accessibility-checker

(Huge thanks to [Bertaç Severcan](https://github.com/bertacsevercan "Bertaç Severcan") for this awesome tool.)

The software itself made it possible for me to create the dataset itself. I analyzed 388 websites. The dataset has 12 variables and 388 observations. Since there are only 3 websites that have an issue with the title attribute we dropped the title column from our dataset. I included 3 types of websites in the dataset. 172 of them is university website, 90 of them is government website of the countries and 126 of them is the eCommerce / retailing websites.

## Results 

![resim](https://user-images.githubusercontent.com/74188001/123255205-3ddfff00-d4f8-11eb-8679-6f673d24a555.png)

Overall university websites and their organizations showed more sensitivity about the accessibility of their website because they have fewer websites with a score of 0 and more in between 75 to 100. This analysis is the same for the governmental websites too. They have more distribution on the score interval of 75 to 100. 

![resim](https://user-images.githubusercontent.com/74188001/123255462-8b5c6c00-d4f8-11eb-86f1-0090475ddb28.png)

The model was not able to interpret or we can say it was not able to explain the Score variable of the model with only has issue predictors. An insignificant result should not be thought of as a total bad result. It shows that it is not possible to analyze the score of a website's accessibility by using only these variables. Whether further 15 changes and implementations to the software and dataset multiple regression model result may be significant and its coefficient can be interpreted.

It should not be forgotten that these results I have obtained are only the results determined according to our criteria. The results I obtained are certainly not concrete results. In this project, my main goal is to detect error spots on websites and to help them fix or improve the website. At the same time, my other aim is to present a dataset to people who want to work on this subject.
