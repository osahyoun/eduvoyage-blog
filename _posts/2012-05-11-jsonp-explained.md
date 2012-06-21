---
layout: post
meta_keywords: javascript, json-p, jsonp, json, ajax
meta_description: Making cross-domain requests. What exactly is JSON-P all about?
comment_id: eduvoyage-3
title: JSON-P - What and Why?
short: JSON-P - What and Why?
pretty_date: Friday, 11 May 2012
---

<p class='intro'>
This post explains JSON-P, a widely used technique for circumnavigating the web browsers security block on cross domain Ajax requests.
</p>

Web browsers support XMLHttpRequest's (Ajax) API for easily retrieving and posting data without reloading the document. The XMLHttpRequest JavaScript object, however, does not support cross-domain requests due to security restrictions imposed by the browser.

So, if I make an Ajax request to Twitter's Search API, I'll be communicating with another domain, and so can expect a security error. Try the following in a JavaScript console on your favourite browser. I'm using Chrome.

{% highlight javascript %}
<script src='http://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js'></script>
// Using jQuery's Ajax API

var resource = '//search.twitter.com/search.json'
$.get(resource, { q:'chimpanzee'})

> XMLHttpRequest cannot load https://search.twitter.com/search.json?q=chimpanzee. Origin https://twitter.com is not allowed by Access-Control-Allow-Origin.

{% endhighlight %}

We get an `XMLHttpRequest cannot load` error, so no surprises there.

I'm sure you're familiar with Twitter's JavaScript widget which one can embed directly into a website. The widget queries Twitter's Search API and displays the results on the page the script is loaded from. But how? Why doesn't the script get the `XMLHttpRequest cannot load` we saw above?

This is how: the widget dynamically injects a `script` tag into the web document. `script` tags are permitted by browsers to load scripts hosted on other domains. So, by dynamically injecting a script tag after your web page has loaded, Twitter's widget can load data into your web document (originating from Twitter's domain) without
having to reload your web page.

Let's give it a try. In the same directory create two documents - `index.html`:

{% highlight html %}
<!DOCTYPE html>
<html>
  <head></head>
  <body>

    <script>

      function get(url){
        // Create script tag
        var scriptTag = document.createElement('script');

        scriptTag.src = url;

        // Inject script tag into the head of the web document
        document.getElementsByTagName('head')[0].appendChild(scriptTag);
      }

      // Call get
      get('data.json');

    </script>

  </body>
</html>
{% endhighlight %}

...and `data.json`:

{% highlight javascript %}
  { animals: [
    'cat',
    'dog',
    'mouse',
    'koala']
  }
{% endhighlight %}


Notice the `get` function in `index.html`. This basic function, when called, dynamically generates and inserts a script tag into the loaded web document, setting `src` to the URL passed.

Load `index.html` in your browser. You'll get a blank window, but reveal the Network panel and you'll see that `data.json` was successfully loaded into our document, despite the script tag being inserted _after_ the web page had loaded.

Browsers immediately run code delivered to the document via a `script` tag. In our example above, we're just returning data - there are no statements to be executed, that's why nothing happens.

The obvious question now is how then do we get our hands on that returned data - currently it's vanishing into the ether...

Well, make the following edit to `data.json`, and refresh `index.html` with the console open:

{% highlight javascript %}
process(
  { animals: [
    'cat',
    'dog',
    'mouse',
    'koala']
  }
);
{% endhighlight %}

Notice the error displayed in the console:

{% highlight javascript %}
Uncaught ReferenceError: process is not defined
{% endhighlight %}

This is a good error to get. It means code is being executed - the function `process` is being invoked. Let's define `process`:

{% highlight javascript %}
<!-- index.html -->

  function get(url){
    var scriptTag = document.createElement('script');
    scriptTag.src = url;
    document.getElementsByTagName('head')[0].appendChild(scriptTag);
  }

  function process(data){
    var body = document.getElementsByTagName('body')[0];
    var h1;

    // Iterate over the array of animals, appending each
    // as a h1 heading, to the document's body
    for(var i = data.animals.length - 1; i >= 0; i--){
      h1 = document.createElement('h1');
      h1.textContent = data.animals[i];
      body.appendChild(h1);
    }
  }

  get('data.json');

{% endhighlight %}

Refresh the browser and you should see a list of animals displayed to the window.

This technique of passing JSON encoded data (which has been requested via a script tag) as an argument to a function is know as JSON-P. How do we get this technique to work with JSON-P savvy API's in the wild?

Returning to Twitter's Search API, take this valid API request and paste it directly into your browser:

{% highlight javascript %}
https://search.twitter.com/search.json?q=chimpanzee
{% endhighlight %}

You'll see, as a response, a page full of JSON encoded data. Twitter's Search API is JSON-P enabled, so, with that in mind, add one additional query parameter (callback) to the URL and reload:

{% highlight javascript %}
https://search.twitter.com/search.json?q=chimpanzee&callback=process
{% endhighlight %}

Notice how Twitter's response has changed? It's now doing exactly what we did in our `data.json` file. It's calling `process`, passing as its only argument the JSON encoded data. Change the value of `callback` and the name of the invoked function changes accordingly.

Let's update our `process` function to work with Twitter's JSON response:

{% highlight javascript %}

function get(url){
  var scriptTag = document.createElement('script');
  scriptTag.src = url;
  document.getElementsByTagName('head')[0].appendChild(scriptTag);
}

function process(data){
  var body = document.getElementsByTagName('body')[0];
  var p;

  for(var i = data.results.length - 1; i >= 0; i--){
    p = document.createElement('p');
    p.textContent = data.results[i].text;
    body.appendChild(p);
  }
}

get('https://search.twitter.com/search.json?q=chimpanzee&callback=process');

{% endhighlight %}

Twitter's API response should now appear on the screen as a list of tweets. We have successfully made a cross-domain request, handling the API's response.

Taking this knowledge with you on future projects, keep in mind not all APIs support JSON-P. Review the API's documentation, or try adding a `callback` parameter and look at the APIs response.

I'll leave you with an improved version of the `get` function from before:

{% highlight javascript %}
var jsonpID = 0;

function JSONP(url, callback){

  // create script tag
  var script = d.createElement('script');

  // Dynamically generate a callback function name.
  // Make the name unique so there's no chance we
  // override another function of the same name. By
  // attaching the counter jsonpID to the name we can make
  // invoke JSONP multiple times, each time with a different
  // function name
  var callbackName = '_JSONP_callback__' + (++jsonpID)

  // replace question mark with callbackName
  script.src = url.replace(/=\?/, '=' + callbackName)

  // append script to document's head
  document.getElementsByTagName('head')[0].appendChild(script)

  // create and assign the callback function
  window[callbackName] = function(data){
    delete window[callbackName]
    // remove script element from document
    script.parentElement.removeChild(script)

    // call the passed function passing data
    callback(data);
  }
}
{% endhighlight %}

You can use `JSONP` as follows:

{% highlight javascript %}
  JSONP('https://search.twitter.com/search.json?q=chimpanzee&callback=?', function(data){
    console.log(data);
  });
{% endhighlight %}

