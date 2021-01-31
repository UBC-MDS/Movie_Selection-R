# Reflection

_Milestone 3, **Group 7**_

## What we have implemented
We adopted our `Python` based [dashboard](https://github.com/UBC-MDS/Movie_Selection) from milestone 2 and re-implemented it in `R`. Our layout is largely similar, including the themes and the placement of components. We also incorporated the feedback from our TA and moved some cards around depending on correlation. We recieved positive feedback for the rest of the layout, including the fixed sidebar, so those remain unchanged.

## What can be improved
One thing that has carried over from the previous milestone as well as from the TA's feedback is the on-click filtering interaction between the top two boxplots with the studios and the scatter plot and the table below. This would provide a streamlined story to the dashboard, as we would go from _less specific_ to _more specific_ as we scroll down.

## Implmentation in `R`

### Advantages
The `R` implementation comes with the usage of `plotly` through `ggplotly` that greatly improves the look and user experience of the dashboard. `Dash` works well with `plotly` and therefore has a lot of components that work responsively (like `Graph`). The switch from `iframe` to `dccGraph` made our app more responsive. Moreover, `ggplotly` should also help us address the improvement mentioned above since we can now hook up callbacks to click events seamlessly. 

### Disadvantages
The development loop of build-run-test is marginally less friendly in the `R` implementation that in `Python` since auto-updating works intermittently. Moreover, deployment with `R` is a more involved process than with `Python`. 

### `Python` vs `R` Thoughts
From our experience, the major drawback of the `R` version is the more intricate deployment process. However, this we only need to learn this once and could possibly automate it. On the other hand, the major positive for the `R` version is the usage of `plotly`. However, it should be easy to re-implement the `Python` dashboard with `plotly` too. The `Python` implementation was more flexible and the designing of the layout was more fluent. 
