<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.hanaonestock.stock.model.dto.RecommendedStock" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/animate.css/4.1.1/animate.min.css"/>
    <link rel="stylesheet" href="../../resources/style/common.css">
    <link rel="stylesheet" href="../../resources/style/dashboard.css">
    <script src="https://code.jquery.com/jquery-3.4.1.min.js"></script>
    <script src="https://unpkg.com/lightweight-charts/dist/lightweight-charts.standalone.production.js"></script>
    <script>
        var cash;
    </script>
</head>
<body>
<header>
    <nav>
        <a href="/">
            <img src="../../resources/img/logo.png" height="40">
        </a>
        <div>
            <ul>
                <li class="nav-list">
                    <a class="nav-menu">서비스소개</a>
                <li class="nav-list">
                    <a class="nav-menu">마이페이지</a>
                <%-- provider 데이터가 "kakao"일 경우 카카오 로그인 버튼을 표시 --%>
                <c:if test="${provider eq 'kakao'}">
                <li class="nav-list">
                    <a href="/oauth/logout" class="nav-menu">로그아웃</a>
                </li>
                </c:if>

                <%-- provider 데이터가 "kakao"가 아닐 경우 일반 로그아웃 버튼을 표시 --%>
                <c:if test="${empty provider}">
                    <li class="nav-list">
                        <a href="/logoutMember" class="nav-menu">로그아웃</a>
                    </li>
                </c:if>
            </ul>
        </div>
    </nav>
</header>
<div class="main">
    <div class="search-menu">
        <div class="a">
            <input class="search-box" type="text" placeholder="🔍 SEARCH">
            <button class="search-button" onclick="handleSearch()">검색</button>
            <div class="search-result"></div>
        </div>
    </div>
</div>
<div class="content">
    <div class="container">
        <!-- 왼쪽 서브 메뉴 -->
        <div class="left_sub_menu">
            <div class="sub_menu">
                <h2>추천종목</h2>
                <c:forEach var="stock" items="${sessionScope.stockList}">
                    <ul class="stock_name">
                        <li><c:out value="${stock.name}" /><i class="arrow fas fa-angle-right"></i></li>
                        <ul class="small_menu">
                            <li>종목번호 <c:out value="${stock.isin}" /></li>
                            <li><c:out value="${stock.close}" /> <c:choose>
                                <c:when test="${stock.updown >= 0}">
                                    <span class="blue_text">+<c:out value="${stock.updown}" />%</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="red_text"><c:out value="${stock.updown}" />%</span>
                                </c:otherwise>
                            </c:choose>
                            </li>
                        </ul>
                    </ul>
                </c:forEach>
                <!--
                <ul class="stock_name">
                    <li>삼성전자<i class="arrow fas fa-angle-right"></i></li>
                    <ul class="small_menu">
                        <li>종목번호 005930</li>
                        <li>69,500 <span class="blue_text"> -0.57%</span></li>
                    </ul>
                </ul>
                <ul class="stock_name">
                    <li>카카오<i class="arrow fas fa-angle-right"></i></li>
                    <ul class="small_menu">
                        <li>종목번호 035720</li>
                        <li>49,850 <span> 0.00%</span></li>
                    </ul>
                </ul>
                -->
                <!-- 종목 추가 누르면 현재 종목 즐겨찾기 추가 -->
                <h2>종목추가➕</h2>
                <div class="add_stock"></div>
            </div>
        </div>
        <div class="chart_div">
            <div class="stock">
                종목이름(종목번호)
            </div>
            <div class="chart">
                <script>
                    var chart = LightweightCharts.createChart(document.querySelector('.chart'), {
                        width: 750,
                        height: 350,
                        rightPriceScale: {
                            visible: true,
                            borderColor: 'rgba(197, 203, 206, 1)',
                        },
                        leftPriceScale: {
                            visible: true,
                            borderColor: 'rgba(197, 203, 206, 1)',
                        },
                        layout: {
                            backgroundColor: '#ffffff',
                            textColor: 'rgba(33, 56, 77, 1)',
                        },
                        grid: {
                            horzLines: {
                                color: '#F0F3FA',
                            },
                            vertLines: {
                                color: '#F0F3FA',
                            },
                        },
                        crosshair: {
                            mode: LightweightCharts.CrosshairMode.Normal,
                        },
                        timeScale: {
                            borderColor: 'rgba(197, 203, 206, 1)',
                        },
                        handleScroll: {
                            vertTouchDrag: false,
                        },
                    });

                    const candlestickSeries = chart.addCandlestickSeries({priceScaleId: 'left'});
                </script>
            </div>
            <div class="trade_div">
                <button type="button" id="toggleButton">매수/매도</button>
                <form id="tradeForm">
                    <input type="hidden" id="isin" name="isin" value="">
                    <input type="hidden" id="id" name="id" value="<%=session.getAttribute("id")%>">
                    <div class="left-column">
                        <div class="form-group">
                            <label for="availableFunds">주문 가능</label>
                            <input type="text" id="availableFunds" name="availableFunds" value="0 KRW" readonly>
                        </div>
                        <div class="form-group">
                            <label for="price">매수 가격</label>
                            <input type="text" id="price" name="price" placeholder="1000 KRW" readonly>
                        </div>
                    </div>
                    <div class="right-column">
                        <div class="form-group">
                            <label for="orderQuantity">주문 수량</label>
                            <input type="text" id="orderQuantity" name="orderQuantity" placeholder="0">
                        </div>
                        <div class="form-group">
                            <label for="quantityPercent">주문 비율</label>
                            <div class="percent-buttons">
                                <button type="button" id="10percent">10%</button>
                                <button type="button" id="25percent">25%</button>
                                <button type="button" id="50percent">50%</button>
                                <button type="button" id="100percent">100%</button>
                            </div>
                        </div>
                    </div>
                    <div class="last-column">
                        <div class="form-group">
                            <label for="totalOrder">주문 총액</label>
                            <input type="text" id="totalOrder" name="totalOrder" readonly>
                        </div>
                        <input type="button" id="buyButton" value="매수하기">
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
<footer>
    <hr>
    <p>
        <span>고객센터 1800-0000</span><br/>
        <span>평일 AM 09:00 ~ PM 18:00 </span><br/>
        <span>서울특별시 영등포구 의사당대로 82(여의도동) | 사업자등록번호 116-81-05992 </span><br/>
        <span>Copyright 2023. HANA-OneStock. All Rights Reserved.</span>
    </p>
    <br>
</footer>

<script>
    /**
     *  검색 창 기능
     */
    $(document).ready(function () {
        $('.search-box').on('input', function () {
            var input = $('.search-box').val();
            $.ajax({
                url: '/stock-searching',  // API endpoint
                type: 'GET',
                data: {
                    'input': input
                },
                success: function (data) {
                    var resultHtml = '';
                    for (var i = 0; i < data.length; i++) {
                        resultHtml += '<div>' + data[i].name + '</div>'; // Assuming 'name' is a property of Stock
                    }
                    $('.search-result').html(resultHtml).show();
                },
                error: function (data) {
                },
            });
        });

        /**
         * Hide the search result when the user clicks outside
         */
        $(document).click(function (event) {
            if (!$(event.target).closest('.searchBar').length) {
                $('.search-result').hide();
            }
        });

        /**
         * Select the search result and fill in the search box
         */
        $(document).on('click', '.search-result div', function () {
            $('.search-box').val($(this).text());
        });
    });

    /**
     * 사용자가 종목 검색 버튼을 클릭할 때 호출
     */
    function handleSearch() {
        const input = $('.search-box').val();
        $.ajax({
            url: "/stock-search",
            type: "GET",
            data: {
                'input': input
            },
            success: function (stock) {
                getUserCash("<%=session.getAttribute("id")%>");
                getChartData(stock.isin);
                $('.stock').text(stock.name + '(' + stock.isin + ')');
                document.getElementById('isin').value = stock.isin;
            },
            error: function () {
                console.log("Error occurred.");
            },
        });
    }

    function getChartData(isin) {
        $.ajax({
            url: "/get-chart",
            type: "GET",
            contentType: "application/json",
            data: {
                'input': isin
            },
            success: function(data) {
                const ohlcvList = JSON.parse(data);
                const candleData = ohlcvList.map((item) => ({
                    close: item.close,
                    high: item.high,
                    low: item.low,
                    open: item.open,
                    time: new Date(item.s_date).toISOString().split('T')[0],
                }));
                // 차트를 그림
                candlestickSeries.setData(candleData);

                // 매수/매도 가격 폼에 종가 적용
                const PriceInput = document.getElementById('price');
                if (candleData.length > 0) {
                    const latestClose = Math.floor(candleData[candleData.length - 1].close); // 소수점 제거
                    PriceInput.value = latestClose.toString(); // 정수로 변환하여 문자열로 표시
                } else {
                    PriceInput.value = ''; // 데이터가 없을 경우 빈 값으로 설정
                }

                // 주문 가능 폼에 사용자 시드를 고려한 최대 주문 가능 액수 적용
                const buyMaxPrice = document.getElementById('availableFunds');
                if (cash < PriceInput.value) {
                    buyMaxPrice.value = 0;
                } else {
                    buyMaxPrice.value = Math.floor(cash / PriceInput.value) * PriceInput.value;
                }

                // 매도의 경우, 최대 주문 수량을 보유하고 있는 주식 수 설정

                //
            },
            error: function () {
                alert("Error occurred.");
            },
        });
    }

    /**
     *  사용자 잔고 받아오기
     */
    function getUserCash(id) {
        $.ajax({
            url: '/get-user-cash',
            type: 'GET',
            data: {
                id: id // 대체할 사용자 식별자
            },
            success: function(data) {
                // 요청이 성공했을 때의 처리
                cash = data;
                console.log('Received cash:', data);
                // data 변수에 서버에서 받아온 cash 값이 들어 있습니다.
                // 이를 원하는 방식으로 처리하십시오.
            },
            error: function(xhr, status, error) {
                // 요청이 실패했을 때의 처리
                console.error('Error:', error);
            }
        });
    }


    function bindEventListeners() {
        document.getElementById('orderQuantity').addEventListener('input', function() {
            const orderQuantity = document.getElementById('orderQuantity').value;
            const price = document.getElementById('price').value;

            if(orderQuantity && price && orderQuantity * price > 0) {
                const totalOrder = orderQuantity * price;
                document.getElementById('totalOrder').value = totalOrder;
            } else {
                document.getElementById('totalOrder').value = '0 KRW';
            }
        });

        ['10', '25', '50', '100'].forEach(function(percent) {
            document.getElementById(percent + 'percent').addEventListener('click', function() {
                const availableFunds = Number(document.getElementById('availableFunds').value.replace(' KRW', ''));
                const price = Number(document.getElementById('price').value.replace(' KRW', ''));

                if(price) {
                    const orderQuantity = (availableFunds * (percent / 100)) / price;
                    const orderQuantityInput = document.getElementById('orderQuantity');

                    orderQuantityInput.value = Math.floor(orderQuantity);
                    orderQuantityInput.dispatchEvent(new Event('input'));
                }
            });
        });

        handleSearch();

        /**
         *  매수 트랜잭션
         */
        $(document).ready(function() {
            $("#buyButton").click(function(event) {
                event.preventDefault();

                var availableFunds = parseInt($("#availableFunds").val());
                var totalOrder = parseInt($("#totalOrder").val());

                if (isNaN(availableFunds) || isNaN(totalOrder)) {
                    alert("주문 가능한 금액이나 주문 총액이 유효한 숫자가 아닙니다.");
                    return;
                }

                if (totalOrder <= availableFunds) {
                    var buyDto = {
                        isin: $('#isin').val(),  // 종목명을 폼에서 가져옵니다.
                        id: $('#id').val(),  // 사용자 아이디를 폼에서 가져옵니다.
                        price: parseInt($('#price').val()),  // 매수가를 폼에서 가져옵니다.
                        volume: parseInt($('#orderQuantity').val()),  // 수량을 폼에서 가져옵니다.
                    };

                    $.ajax({
                        type: 'POST',
                        url: '/buy-transaction',
                        data: JSON.stringify(buyDto),
                        contentType: 'application/json',
                        success: function() {
                            alert('Transaction success!');
                            location.reload();
                        },
                        error: function() {
                            alert('Transaction failed!');
                            location.reload();
                        },
                    });
                } else {
                    alert("주문 가능한 금액보다 주문 총액이 더 큽니다.");
                }
            });
        });

        /**
         * 매도 트랜잭션
         */
        $(document).ready(function() {
            $("#sellButton").click(function(event) {
                event.preventDefault();

                var sellDto = {
                    isin: $('#isin').val(),  // 종목명을 폼에서 가져옵니다.
                    id: $('#id').val(),  // 사용자 아이디를 폼에서 가져옵니다.
                    price: parseInt($('#price').val()),  // 매도가를 폼에서 가져옵니다.
                };
                $.ajax({
                    type: 'POST',
                    url: '/sell-transaction',  // 매도 요청을 처리하는 서버의 URL입니다.
                    data: JSON.stringify(sellDto),
                    contentType: 'application/json',
                    success: function() {
                        alert('Transaction success!');
                        location.reload();
                    },
                    error: function() {
                        console.log($('#isin').val());
                        console.log($('#id').val());
                        console.log(parseInt($('#price').val()));
                        alert('Transaction failed!');
                        //location.reload();
                    },
                });
            });
        });

    }

    // 매수/매도 폼 변경
    var toggleButton = document.getElementById("toggleButton");
    var tradeForm = document.getElementById("tradeForm");
    var isBuyForm = true;
    toggleButton.addEventListener("click", function () {
        if (isBuyForm) {
            tradeForm.innerHTML = `
                    <input type="hidden" id="isin" name="isin" value="">
                    <input type="hidden" id="id" name="id" value="<%=session.getAttribute("id")%>">
                    <div class="left-column">
                        <div class="form-group">
                            <label for="price">매도 가격</label>
                            <input type="text" id="price" name="price" placeholder="1000 KRW">
                        </div>
                    </div>
                    <div class="right-column">
                        <div class="form-group">
                            <label for="orderQuantity" hidden>주문 수량</label>
                            <input type="text" id="orderQuantity" name="orderQuantity" placeholder="0" hidden>
                        </div>
                    </div>
                    <div class="form-group" hidden>
                        <label for="quantityPercent" hidden>주문 비율</label>
                        <div class="percent-buttons" hidden>
                            <button type="button" id="10percent" hidden>10%</button>
                            <button type="button" id="25percent" hidden>25%</button>
                            <button type="button" id="50percent" hidden>50%</button>
                            <button type="button" id="100percent" hidden>100%</button>
                        </div>
                    </div>
                    <div class="last-column">
                        <div class="form-group" hidden>
                            <label for="totalOrder" hidden>주문 총액</label>
                            <input type="text" id="totalOrder" name="totalOrder" readonly hidden>
                        </div>
                        <input type="button" id="sellButton" value="매도하기">
                    </div>
                `;
            toggleButton.innerText = "매수하기";
        } else {
            tradeForm.innerHTML = `
                    <input type="hidden" id="isin" name="isin" value="">
                    <input type="hidden" id="id" name="id" value="<%=session.getAttribute("id")%>">
                    <div class="left-column">
                        <div class="form-group">
                            <label for="availableFunds">주문 가능</label>
                            <input type="text" id="availableFunds" name="availableFunds" value="0 KRW" readonly>
                        </div>
                        <div class="form-group">
                            <label for="price">매수 가격</label>
                            <input type="text" id="price" name="price" placeholder="1000 KRW" readonly>
                        </div>
                    </div>
                    <div class="right-column">
                        <div class="form-group">
                            <label for="orderQuantity">주문 수량</label>
                            <input type="text" id="orderQuantity" name="orderQuantity" placeholder="0">
                        </div>
                        <div class="form-group">
                            <label for="quantityPercent">주문 비율</label>
                            <div class="percent-buttons">
                                <button type="button" id="10percent">10%</button>
                                <button type="button" id="25percent">25%</button>
                                <button type="button" id="50percent">50%</button>
                                <button type="button" id="100percent">100%</button>
                            </div>
                        </div>
                    </div>
                    <div class="last-column">
                        <div class="form-group">
                            <label for="totalOrder">주문 총액</label>
                            <input type="text" id="totalOrder" name="totalOrder" readonly>
                        </div>
                        <input type="button" id="buyButton" value="매수하기">
                    </div>
                `;
            toggleButton.innerText = "매도하기";
        }
        isBuyForm = !isBuyForm;
        bindEventListeners();
    });

    $(document).ready(function () {
        // 종목추가 클릭 이벤트
        $('h2:contains("종목추가")').on('click', function () {
            // 종목 정보 가져오기
            var stockInfo = $('.stock').text().trim(); // "삼성전자(005930)"

            // 이미 추가된 종목인지 확인
            var isAlreadyAdded = false;
            $('.stock_name > li').each(function () {
                if ($(this).text().indexOf(stockInfo) >= 0) { // 종목 이름과 번호가 포함되어 있는지 확인
                    isAlreadyAdded = true;
                    return false; // each loop 탈출
                }
            });

            // 이미 추가된 종목이라면 추가하지 않음
            if (isAlreadyAdded) return;

            // 종가, 등락률 정보 가져오기 (일단 대기)
            /*
            var closingPrice = '69,500'; // 임시 값
            var fluctuationRate = '-0.57%'; // 임시 값
            */
            // 리스트 요소 추가
            var newListItem = $(
                '<ul class="stock_name">' +
                '<li>' + stockInfo + '<i class="arrow fas fa-angle-right"></i></li>' +
                /*
                '<ul class="small_menu">' +
                '<li>' + closingPrice + ' <span class="blue_text"> ' + fluctuationRate + '</span></li>' +
                '</ul>' +*/
                '</ul>'
            );

            $('.add_stock').append(newListItem);

            // 클릭 이벤트 추가
            newListItem.on('click', 'li', function () {
                var name = $(this).text().trim().split('(')[0].replace(')', ''); // 종목 명 추출
                var isin = $(this).text().trim().split('(')[1].replace(')', ''); // 종목 번호(ISIN) 추출
                $('.stock').text(name + '(' + isin + ')');
                getChartData(isin); // 차트 데이터 가져오기
            });
        });
    });
    bindEventListeners();
</script>
</body>
</html>