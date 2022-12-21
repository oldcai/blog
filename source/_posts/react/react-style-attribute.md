---
title: Avoiding Using React Style Attribute
date: 2022-12-21 15:20:28
tags:
	- CSS
---


## Why Not Using Style Attributes in React?

In react, the style attribute will force the browser to re-render the component every time due to the style object being new every react render.

There are two ways to solve this problem.


### Use a Class

In general, updating the `style` attribute of a React component on every render is not a good practice. This can cause the browser to unnecessarily re-render the component and impact performance.

Instead, it is recommended to use a CSS class to define the styles for a component and then apply the class to the component using the className prop. This allows the styles to be cached by the browser, improving performance.

Here is an example of how you might do this:

```
import React from 'react';
import './App.css'; // Import your CSS file

function MyComponent(props) {
  return (
    <div className="my-component">
      {/* The component will be styled using the styles defined in the .my-component class in the CSS file */}
    </div>
  );
}
```

### Define the Style Object Outside the Component

Alternatively, you can use the style prop to apply inline styles to a component, but you should make sure to only update the style object when it is necessary. For example, you might define the style object outside of the component and only update it when specific props or state values change. This will ensure that the style object is not recreated on every render.

```
import React from 'react';

const styles = {
  color: 'red',
  fontSize: '24px',
};

function MyComponent(props) {
  return (
    <div style={styles}>
      {/* The component will be styled using the inline styles defined in the styles object */}
    </div>
  );
}
```

This code example shows how to save the Style Object Outside the Component so that it's always the same instance.

