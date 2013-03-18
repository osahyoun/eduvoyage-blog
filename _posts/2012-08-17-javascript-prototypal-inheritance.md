---
layout: show
meta_keywords: javascript, prototypes, prototypal inheritance, twitter, tweet, objects
meta_description: A look at Prototypal Inheritance in JavaScript
comment_id: eduvoyage-5
title: JavaScript Objects, Prototypes and a Tweet
pretty_date: Friday, 17 August 2012
extract: A look at Prototypal Inheritance in JavaScript
---

<p class='intro'>
A look at Prototypal Inheritance in JavaScript and how we can implement it.
</p>

Here we have a JavaScript object, describing a single tweet...

{% highlight javascript %}
var tweet = {
  "created_at": "Sun, 05 Aug 2012 10:30:12 +0000",
  "from_user": "NME",
  "id": 231185161608376321,
  "id_str": "231185161608376321",
  "profile_image_url": "http:\/\/a0.twimg.com\/profile_images\/1731598749\/twitter3_normal.jpg",
  "text": "Arctic Monkeys set to score a Top 20 hit with their cover of The Beatles' 'Come Together' http:\/\/t.co\/1GvDZXoc"
};
{% endhighlight %}

...from which we can extract information:

{% highlight javascript %}
tweet.text;
// Using dot notation.
// Returns Artic Monkeys set to score...

// Or...

tweet['text'];
// Using bracket notation.
// Also returns Artic Monkeys set to score...
{% endhighlight %}

We can derive new information from the tweet, such as the tweet's full HTTP address. Here's a short function for the job:

{% highlight javascript %}
// function 'where' takes a tweet object and returns a URL string,
// constructed from the properties of the passed tweet.

var where = function(tweet) {
  return "https://twitter.com/" + tweet.from_user + "/status/" + tweet.id_str;
};

// Invoking the function
where(tweet);

// Returns https://twitter.com/NME/status/231185161608376321
{% endhighlight %}

As it stands, we need to pass our object to the function `where`, but what if we could ask the object directly, like so:

{% highlight javascript %}
tweet.where();
{% endhighlight %}

Not a problem. We just need to make the function a property of the object:

{% highlight javascript %}
tweet.where = function() {
  return "https://twitter.com/" + this.from_user + "/status/" + this.id_str;
}

tweet.where();
// Returns https://twitter.com/NME/status/231185161608376321
{% endhighlight %}

Notice above I'm using <a title='JavaScript this' href='http://www.unicodegirl.com/javascript-this-keyword.html'>JavaScript's <strong>this</strong></a> keyword for accessing `a_tweets` properties.

### Working with Multiple Objects

What if we have an array of tweets and we want each object to respond to `where`?

{% highlight javascript %}

// Loop through array of tweets, assigning copy of the
// 'where' function to each tweet object.
for(var x, length = tweets.length; x < length; x++){
  tweets[x].where = function(){
    return "https://twitter.com/" + this.user_name + "/status/" + this.tweet_id;
  }
}

tweets[0].where();
{% endhighlight %}

Assigning a copy of the 'where' function to every tweet isn't a very efficient use of memory or code. What if we could have one instance of the `where` function and have all the tweet objects access that instance. This is where Prototypal Inheritance steps forward. 

### Prototypal Inheritance
Any JavaScript object can have a pointer to an object called its prototype. Multiple objects can all have the same prototype. Crucially, objects inherit properties from their prototypes:

{% highlight javascript %}
// Here's an empty object created using Object constructor's 'create' method:

var emptyObject = Object.create(null);

// When creating new objects with this method, you can set the object's prototype 
// by passing the aspiring prototype object:

// Elixir is a regular JavaScript object, created using object literal notation. It will act as our prototype.
var elixir = {
  'immortal': true
};

// Create a new object passing elixir
var mortalObject = Object.create(elixir);

mortalObject.immortal;
// Returns true!
{% endhighlight %}

`mortalObject` is inheriting immortality from its prototype object (the `elixir` object).

Other objects can drink from the elixir of life too:

{% highlight javascript %}
var ordinaryObject = Object.create(elixir);

ordinaryObject.immortal;
// Returns true

// What if the elixir runs dry?

elixir.immortal = false;

// Now all objects inheriting from elixir have lost their immortality:

ordinaryObject.immortal;
// Returns false

mortalObject.immortal;
// Returns false
{% endhighlight %}

With that very brief tour of JavaScript prototypes, we can return to our tweets example. Using prototypal inheritance, we'll endow the tweets with the 'where' method:

{% highlight javascript %}
var cortex = {
  where: function(){
    return "https://twitter.com/" + this.username + "/status/" + this.id;
  }
};
{% endhighlight %}

`cortex` will be the prototype object our tweet objects will inherit from:

{% highlight javascript %}
// Helper function takes a regular tweet object

function generateSmartTweet(tweet){
  var obj = Object.create(cortex)
  obj.id = tweet.id_str;
  obj.text = tweet.text;
  obj.username = tweet.from_user;
  return obj;
}

// Container for our smart tweets
var smart_tweets = [];

// Iterate over our array of tweets passing each tweet to generateSmartTweet,
// pushing the returned 'smart' tweet to our smart tweets array.

for(var x, var length = tweets.length; x < length; x++){
  smart_tweets.push(generateSmartTweet(tweets[x]));
}

smart_tweets[0].where();
// Returns https://twitter.com/NME/status/231185161608376321
{% endhighlight %}

All tweets whose prototype object is the cortex will immediately have access to any new methods we assign to the cortex. Perhaps we'd like to know how long ago in words the tweet was tweeted? I won't re-invent the wheel for this method - below is some code [borrowed from John Resig](http://ejohn.org/blog/javascript-pretty-date/) (of jQuery fame):


{% highlight javascript %}
// I'll pop this function into another, more generic object (`Helper`). 
// It has general appeal, and could be used by other code.
var Helper = {};

Helper.timeAgoInWords = function(time){
    var date = new Date((time || "").replace(/-/g,"/").replace(/[TZ]/g," ")),
      diff = (((new Date()).getTime() - date.getTime()) / 1000),
      day_diff = Math.floor(diff / 86400);

    if ( isNaN(day_diff) || day_diff < 0 || day_diff >= 31 )
      return;

    return day_diff == 0 && (
        diff < 60 && "just now" ||
        diff < 120 && "1 minute ago" ||
        diff < 3600 && Math.floor( diff / 60 ) + " minutes ago" ||
        diff < 7200 && "1 hour ago" ||
        diff < 86400 && Math.floor( diff / 3600 ) + " hours ago") ||
      day_diff == 1 && "Yesterday" ||
      day_diff < 7 && day_diff + " days ago" ||
      day_diff < 31 && Math.ceil( day_diff / 7 ) + " weeks ago";
    }
  }
};

// Back to the cortex...
var cortex = {
  where: function(){
    return "https://twitter.com/" + this.user_name + "/status/" + this.tweet_id;
  },

  when: function(){
    return Helper.timeAgoInWords(this.created_at);
  }
};
{% endhighlight %}

It would also be handy if we could have the tweet text 'linkified' for us:

{% highlight javascript %}
cortex.linkified_text = function(){
    var text = this.text;
    var url_expression = /([A-Za-z]+:\/\/[A-Za-z0-9-_]+\.[A-Za-z0-9-_:%&\?\/.=]+)/g;
    var username_expression = /(^|\s)@(\w+)/g;
    var hash_expression = /(^|\s)#(\w+)/g;

    return text.replace(url_expression, '<a href="$1" target="_blank">$1</a>').
                replace(username_expression, '$1@<a href="http://www.twitter.com/$2" target="_blank">$2</a>').
                replace(hash_expression, '$1#<a href="http://search.twitter.com/search?q=%23$2" target="_blank">$2</a>');
};


smart_tweets[0].linkified_text();
// Returns something like @<a href="http://www.twitter.com/foo target="_blank">foo</a> #<a href="http://search.twitter.com/search?q=%23baa" target="_blank">baa</a> <a href="http://google.com" target="_blank">http://google.com</a>
{% endhighlight %}
    
And with that, we have an example (with some practical value) of how JavaScript's prototypal inheritance allows objects to easily inherit from other, more general objects.