# plague_simulation

Симуляция жизни небольшого города создана в качестве учебной цели при изучении возможностей Processing3 (java). Какую-то математическую модель не реализует.

Жители ходят на работу, возвращаются после работы домой, могут ходить в "магазины". Заражение начинается с произвольно выбранного жителя, который может передать вирус (после инкубационного периода) на расстоянии 1 клетки вне здания ли на 2 клеток в помещении. После окончания активной фазы, житель с 5% вероятностью может умереть (если он в это время в "госпитале" шанс только 2,5%). Если житель выздоровел, получает на ~21 день иммунитет. При заболевании, житель с может решить сходить в больницу "провериться", где с вероятностью 25% вирус может быть обнаружен, тогда, если в поликлинике хватает мест (сейчас 25 мест) он может лечиться там, иначе, он вернётся домой и будет лечиться там (не будет ходить на работу и в "магазины"). "Магазины", "офисы" и даже "квартиры" генерируют некоторые баллы "продукции", когда там находятся жильцы. "Магазины" - немного экономики, развития социума и чуть больше счастья (общего), "офисы" - много экономики, "квартиры" - немного счастья и социума. "Госпитали" потребляют экономику и счастье. 

Условные обозначения

Зеленая точка - здоровый житель
Черная точки - зараженный житель на стадии инкубационного периода
Красная точки - зараженный житель на активной стадии вируса
Желтая точки - здоровый житель с иммунитетом к вирусу

Желтый квадрат - квартира
Синий квадрат - магазин (магазин, банк, точки потребительских услуг и т.п.)
Фиолетовый квадрат - офисы
Белый квадрат - госпиталь

Графики:
Красный - зараженные жители по отношению к общему числу живых
Желтый (под красным) - количество выявленных заболеваний по отношению к заболевшим
Серая вертикаль - "ноль" - стартовая точка продуктов экономики
Зеленый график - социалка
Синий график - счастье
Фиолетовый график - экономика
Вертикальный быстрые голубой график - кадры в секунду

