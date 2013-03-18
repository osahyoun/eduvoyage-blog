---
layout: show
meta_keywords: javascript, json, objects, twitter, api
meta_description: Got something to say? Then say it in JSON, and let the internet revel in your message.
comment_id: eduvoyage-4
title: Love Thy JSON
pretty_date: Saturday, 28 July 2012
extract: JSON is fantastic stuff. Learn to love it, if you want to reach Web Dev Nirvana.
---

<p class='intro'>
  {{ page.extract }}
</p>

As an aspiring Web App developer, it's important you get down and dirty with JSON. 

### What is JSON?

Simply, JSON is a data format. It's a standardised way of formatting structured information. When you query almost any API today, it's going to format its response in JSON -  copy and paste this query into your browser to see what I mean:

  `http://search.twitter.com/search.json?q=monkey` 
  
Twitter's response is a screen full of JSON formatted tweets about monkeys. Notice how JSON is very readable - it is actually based on a subset of JavaScript. If you're familiar with JavaScript objects, then you're going to find JSON a breeze.

What follows is a simple demonstration of what JSON looks like and how we can can work with it in a web environment.

Fire up your JavaScript console, and follow along:

{% highlight javascript %}
// Here's a JSON object of someone's name:

'{"firstname": "Tim", "surname" : "Berners-Lee"}'
{% endhighlight %}

With JavaScript, let's try and extract some information out of it. 

{% highlight javascript %}

var obj = '{"firstname": "Tim", "surname" : "Berners-Lee"}';
typeof obj;
>> "string"

// We can't get much out of a string, without complicated RegExp pattern matching. 
// JSON.parse to the rescue...

obj = JSON.parse(obj);
typeof obj;
>> "object"

// Nice. We now have a JavaScript object!

obj.firstname;
>> "Tim"

// OK. Let's write a simple function which takes the above object and returns a full name:

function fullName(person){
  return person.firstname + ' ' + person.surname;
}

fullName(obj);

>> "Tim Berners-Lee"

{% endhighlight %}


Often, when working with JSON responses from APIs, you'll get an array of objects. Here's an example from Twitter's search API (the response has been heavily trimmed, for brevity's sake).

{% highlight javascript %}

{
  "completed_in": 0.125,
  "max_id_str": "229283820036304896",
  "next_page": "?page=2&max_id=229283820036304896&q=blue%20angels&rpp=5&include_entities=1&result_type=mixed",
  "page": 1,
  "query": "blue+angels",
  "results": [
    {
      "created_at": "Sat, 28 Jul 2012 18:34:57 +0000",
      "from_user": "msinfoblog",
      "from_user_name": "Kelley  Wilson",
      "profile_image_url": "http:\/\/a0.twimg.com\/profile_images\/2287764130\/2tmsb7eyhs9v7qkvdbps_normal.png",
      "text": "On our way to the blue Angels air museum http:\/\/t.co\/FJFDRUG1"
    }, 
    {
      "created_at": "Sat, 28 Jul 2012 18:29:22 +0000",
      "from_user": "papawheelee",
      "from_user_name": "Jeremy Wheelock",
      "profile_image_url": "http:\/\/a0.twimg.com\/profile_images\/2317606886\/1339975449024_normal.jpg",
      "text": "They look fast parked. @Brad202b: Blue angels http:\/\/t.co\/aA4VCL2s"
    }, 
    {
      "created_at": "Sat, 28 Jul 2012 18:26:50 +0000",
      "from_user": "preciousalexan2",
      "from_user_name": "precious alexander",
      "profile_image_url": "http:\/\/a0.twimg.com\/sticky\/default_profile_images\/default_profile_0_normal.png",
      "text":"RT @ShamraStar: My Angels gave me pink purple &amp; blue kisses! @starquality @pinkyinthebrain @my_dollhouse \ud83d\ude18 http:\/\/t.co\/oC5OVNh9"
    }
  ]
}
{% endhighlight %}

See just *how* readable JSON is? Notice the `results` property 6 lines down, this is where all the action is at. The property's value is an array of tweets. Let's programmatically do something with that data...

{% highlight javascript %}

// JSON segment from above, duplicated below as a string, 
// on one line so you can copy and paste into your browser's JavaScript console.

var data = '{"completed_in":0.125,"max_id_str":"229283820036304896","next_page":"?page=2&max_id=229283820036304896&q=blue%20angels&rpp=5&include_entities=1&result_type=mixed","page":1,"query":"blue+angels","results":[{"created_at":"Sat, 28 Jul 2012 18:34:57 +0000","from_user":"msinfoblog","from_user_name":"Kelley  Wilson","profile_image_url":"http:\/\/a0.twimg.com\/profile_images\/2287764130\/2tmsb7eyhs9v7qkvdbps_normal.png","text":"On our way to the blue Angels air museum http:\/\/t.co\/FJFDRUG1"},{"created_at":"Sat, 28 Jul 2012 18:29:22 +0000","from_user":"papawheelee","from_user_name":"Jeremy Wheelock","profile_image_url":"http:\/\/a0.twimg.com\/profile_images\/2317606886\/1339975449024_normal.jpg","text":"They look fast parked. @Brad202b: Blue angels http:\/\/t.co\/aA4VCL2s"},{"created_at":"Sat, 28 Jul 2012 18:26:50 +0000","from_user":"preciousalexan2","from_user_name":"precious alexander","profile_image_url":"http:\/\/a0.twimg.com\/sticky\/default_profile_images\/default_profile_0_normal.png","text":"RT @ShamraStar: My Angels gave me pink purple &amp; blue kisses! @starquality @pinkyinthebrain @my_dollhouse \ud83d\ude18 http:\/\/t.co\/oC5OVNh9"}]}'

typeof data;
// "string"

data = JSON.parse(data);
typeof data
// "object"

data.results;
// [> Object, > Object, > Object]

data.results[0].text;
// "On our way to the blue Angels air museum http://t.co/FJFDRUG1"

function showTweets(tweets){
  for (var i=0; i < tweets.length; i++) {
    console.log(i+1 + '.',tweets[i].text, 'by', tweets[i].from_user_name);
  };
}

showTweets(data.results);

// 1. On our way to the blue Angels air museum http://t.co/FJFDRUG1 by Kelley  Wilson
// 2. They look fast parked. @Brad202b: Blue angels http://t.co/aA4VCL2s by Jeremy Wheelock
// 3. RT @ShamraStar: My Angels gave me pink purple &amp; blue kisses! @starquality @pinkyinthebrain @my_dollhouse http://t.co/oC5OVNh9 by precious alexander

{% endhighlight %}

I'll post some short tutorials over the coming weeks, exploring further the significance of JSON in Web App Development. In the mean time, have a peep at the following:

+   [Introducing JSON](http://json.org// "Introducing JSON")
+   [Look who's using JSON](http://www.programmableweb.com/apis/directory/1?format=JSON "APIs spitting out JSON")
