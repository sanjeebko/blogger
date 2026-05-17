# Blog Quality: Bad vs Good Examples

This document shows concrete examples of what NOT to do and what TO do when writing blog posts.

---

## Example 1: Code Explanation

### ❌ BAD - Too Brief, No Context

```html
<section>
  <h2>Using Signals</h2>
  <p>Signals are reactive in Angular.</p>
  <pre><code>const count = signal(0);</code></pre>
  <p>That's how you use it.</p>
</section>
```

**Problems:**

- Only 15 words of explanation
- No context or why it matters
- No explanation before or after code
- No syntax highlighting
- Doesn't help reader understand

### ✅ GOOD - Detailed with Context

```html
<section>
  <h2>Understanding Signals: Angular's Reactive Primitives</h2>
  <p>
    Signals represent a fundamental shift in how Angular handles reactivity.
    Unlike traditional change detection that relies on Zone.js to intercept
    every asynchronous operation in your application, Signals provide an
    explicit, fine-grained reactivity model. This means Angular knows exactly
    what changed and can update only the affected parts of your UI—no more
    checking the entire component tree on every async event.
  </p>

  <div class="info-box">
    <strong>📘 What is a Signal?</strong>
    <p>
      A Signal is a wrapper around a value that notifies interested consumers
      when that value changes. Think of it as an observable with better
      TypeScript integration and zero dependency on RxJS. It's Angular's answer
      to the reactivity systems in Vue 3 (ref) and Solid.js (createSignal).
    </p>
  </div>

  <h3>Creating Your First Signal</h3>
  <p>
    Let's create a simple counter using Signals. The
    <code>signal()</code> function accepts an initial value and returns a Signal
    object that you can read and write. Here's the basic syntax:
  </p>

  <pre><code><span class="highlight-keyword">import</span> { signal } <span class="highlight-keyword">from</span> <span class="highlight-string">'@angular/core'</span>;

<span class="highlight-comment">// Create a Signal with initial value of 0</span>
<span class="highlight-keyword">const</span> count = <span class="highlight-function">signal</span>(<span class="highlight-number">0</span>);

<span class="highlight-comment">// Read the value by calling it as a function</span>
<span class="highlight-function">console.log</span>(count()); <span class="highlight-comment">// Output: 0</span>

<span class="highlight-comment">// Update the value using set() - replaces the current value</span>
count.<span class="highlight-function">set</span>(<span class="highlight-number">5</span>);
<span class="highlight-function">console.log</span>(count()); <span class="highlight-comment">// Output: 5</span>

<span class="highlight-comment">// Or update based on previous value using update()</span>
count.<span class="highlight-function">update</span>(current => current + <span class="highlight-number">1</span>);
<span class="highlight-function">console.log</span>(count()); <span class="highlight-comment">// Output: 6</span></code></pre>

  <p>
    Notice the three core operations: <strong>create</strong> with
    <code>signal(initialValue)</code>, <strong>read</strong> by calling the
    signal as a function, and <strong>write</strong> with either
    <code>set(newValue)</code> or <code>update(fn)</code>. The distinction
    between set and update is important: use <code>set()</code> when you have a
    new value to assign, and <code>update()</code> when computing the new value
    based on the current one. This prevents race conditions in scenarios where
    multiple updates might occur simultaneously.
  </p>

  <div class="tip-box">
    <strong>💡 Pro Tip</strong>
    <p>
      Always use <code>update()</code> instead of
      <code>set(count() + 1)</code> when modifying based on the current value.
      The update function receives the current value atomically, preventing bugs
      in async code where the value might change between when you read it and
      when you set it.
    </p>
  </div>
</section>
```

**Why this is good:**

- 350+ words of detailed explanation
- Explains WHY Signals matter (performance, precision)
- Provides context (compares to Zone.js, mentions other frameworks)
- Info box defines the concept clearly
- Code example is complete and well-commented
- Every line of code is explained
- Syntax highlighting applied correctly
- Tip box adds practical advice
- Helps reader truly understand, not just copy-paste

---

## Example 2: Real-World Example Section

### ❌ BAD - Just Code, No Context

```html
<section>
  <h2>Example</h2>
  <pre><code>class TodoComponent {
  todos = signal([]);
  
  addTodo(text) {
    this.todos.update(list => [...list, {text}]);
  }
}</code></pre>
</section>
```

**Problems:**

- No scenario description
- No step-by-step breakdown
- Incomplete code (no imports, no template)
- No explanation of what's happening
- No syntax highlighting

### ✅ GOOD - Complete Scenario with Steps

```html
<section>
  <h2>Real-World Example: Building a Task Management Dashboard</h2>
  <p>
    Let's build a practical task manager that demonstrates how Signals, computed
    values, and the new control flow work together. Our dashboard will display
    tasks, filter them by status, and show real-time statistics—all with minimal
    change detection overhead.
  </p>

  <div class="example-box">
    <strong>📋 Example Scenario</strong>
    <p>
      Imagine you're building a project management tool where users can add
      tasks, mark them complete, and filter by status. The dashboard needs to
      show live statistics (total tasks, completion percentage) that update
      automatically as tasks change. This is a perfect use case for Signals and
      computed values.
    </p>
  </div>

  <h3>Step 1: Define the Data Model and Component Structure</h3>
  <p>
    First, we'll set up our component with a Signal to hold the task list.
    Notice we're using a strongly-typed interface to ensure type safety
    throughout:
  </p>

  <pre><code><span class="highlight-keyword">import</span> { Component, signal, computed } <span class="highlight-keyword">from</span> <span class="highlight-string">'@angular/core'</span>;

<span class="highlight-keyword">interface</span> <span class="highlight-class">Task</span> {
  id: <span class="highlight-keyword">number</span>;
  title: <span class="highlight-keyword">string</span>;
  completed: <span class="highlight-keyword">boolean</span>;
  priority: <span class="highlight-string">'low'</span> | <span class="highlight-string">'medium'</span> | <span class="highlight-string">'high'</span>;
}

<span class="highlight-keyword">@Component</span>({
  selector: <span class="highlight-string">'app-task-dashboard'</span>,
  standalone: <span class="highlight-keyword">true</span>,
  templateUrl: <span class="highlight-string">'./task-dashboard.component.html'</span>
})
<span class="highlight-keyword">export class</span> <span class="highlight-class">TaskDashboardComponent</span> {
  <span class="highlight-comment">// Signal holding our task list</span>
  tasks = signal&lt;<span class="highlight-class">Task</span>[]&gt;([
    { id: <span class="highlight-number">1</span>, title: <span class="highlight-string">'Review PR #245'</span>, completed: <span class="highlight-keyword">false</span>, priority: <span class="highlight-string">'high'</span> },
    { id: <span class="highlight-number">2</span>, title: <span class="highlight-string">'Update documentation'</span>, completed: <span class="highlight-keyword">true</span>, priority: <span class="highlight-string">'low'</span> },
    { id: <span class="highlight-number">3</span>, title: <span class="highlight-string">'Fix bug in auth service'</span>, completed: <span class="highlight-keyword">false</span>, priority: <span class="highlight-string">'high'</span> }
  ]);

  <span class="highlight-comment">// Signal for current filter</span>
  filterStatus = signal&lt;<span class="highlight-string">'all'</span> | <span class="highlight-string">'active'</span> | <span class="highlight-string">'completed'</span>&gt;(<span class="highlight-string">'all'</span>);
}</code></pre>

  <p>
    We've initialized our component with two Signals: one for the task list
    (starting with three sample tasks) and one for the current filter status.
    The TypeScript types ensure we can't accidentally set invalid priority
    levels or filter values.
  </p>

  <h3>Step 2: Add Computed Values for Filtered Lists and Statistics</h3>
  <p>
    Now we'll add computed Signals that automatically recalculate when the
    underlying tasks or filter changes. This is where Signals really shine—no
    manual subscription management needed:
  </p>

  <pre><code>  <span class="highlight-comment">// Computed: Filtered task list based on current filter</span>
  filteredTasks = <span class="highlight-function">computed</span>(() => {
    <span class="highlight-keyword">const</span> filter = <span class="highlight-keyword">this</span>.filterStatus();
    <span class="highlight-keyword">const</span> allTasks = <span class="highlight-keyword">this</span>.tasks();
    
    <span class="highlight-control">if</span> (filter === <span class="highlight-string">'active'</span>) {
      <span class="highlight-control">return</span> allTasks.<span class="highlight-function">filter</span>(t => !t.completed);
    } <span class="highlight-control">else if</span> (filter === <span class="highlight-string">'completed'</span>) {
      <span class="highlight-control">return</span> allTasks.<span class="highlight-function">filter</span>(t => t.completed);
    }
    <span class="highlight-control">return</span> allTasks;
  });

  <span class="highlight-comment">// Computed: Total number of tasks</span>
  totalTasks = <span class="highlight-function">computed</span>(() => <span class="highlight-keyword">this</span>.tasks().length);

  <span class="highlight-comment">// Computed: Number of completed tasks</span>
  completedCount = <span class="highlight-function">computed</span>(() => 
    <span class="highlight-keyword">this</span>.tasks().<span class="highlight-function">filter</span>(t => t.completed).length
  );

  <span class="highlight-comment">// Computed: Completion percentage</span>
  completionPercentage = <span class="highlight-function">computed</span>(() => {
    <span class="highlight-keyword">const</span> total = <span class="highlight-keyword">this</span>.totalTasks();
    <span class="highlight-control">if</span> (total === <span class="highlight-number">0</span>) <span class="highlight-control">return</span> <span class="highlight-number">0</span>;
    <span class="highlight-control">return</span> <span class="highlight-function">Math.round</span>((<span class="highlight-keyword">this</span>.completedCount() / total) * <span class="highlight-number">100</span>);
  });</code></pre>

  <p>
    Each computed Signal automatically tracks its dependencies. When
    <code>tasks()</code> changes, all four computed Signals recalculate. When
    <code>filterStatus()</code> changes, only
    <code>filteredTasks()</code> recalculates. Angular handles this dependency
    tracking for you—no manual subscription setup required.
  </p>

  <h3>Step 3: Add Methods to Manage Tasks</h3>
  <p>
    Now let's add methods to add tasks, toggle completion status, and delete
    tasks. Notice how we use <code>update()</code> to modify the array
    immutably:
  </p>

  <pre><code>  <span class="highlight-function">addTask</span>(title: <span class="highlight-keyword">string</span>, priority: <span class="highlight-class">Task</span>[<span class="highlight-string">'priority'</span>]) {
    <span class="highlight-keyword">const</span> newTask: <span class="highlight-class">Task</span> = {
      id: <span class="highlight-class">Date</span>.<span class="highlight-function">now</span>(), <span class="highlight-comment">// Simple ID generation</span>
      title,
      completed: <span class="highlight-keyword">false</span>,
      priority
    };
    
    <span class="highlight-comment">// Immutably add new task to array</span>
    <span class="highlight-keyword">this</span>.tasks.<span class="highlight-function">update</span>(current => [...current, newTask]);
  }

  <span class="highlight-function">toggleTask</span>(id: <span class="highlight-keyword">number</span>) {
    <span class="highlight-keyword">this</span>.tasks.<span class="highlight-function">update</span>(current =>
      current.<span class="highlight-function">map</span>(task =>
        task.id === id ? { ...task, completed: !task.completed } : task
      )
    );
  }

  <span class="highlight-function">deleteTask</span>(id: <span class="highlight-keyword">number</span>) {
    <span class="highlight-keyword">this</span>.tasks.<span class="highlight-function">update</span>(current => 
      current.<span class="highlight-function">filter</span>(task => task.id !== id)
    );
  }</code></pre>

  <p>
    These methods demonstrate best practices for Signal updates: always treat
    the Signal's value as immutable. Instead of pushing to the array directly
    (which wouldn't trigger updates), we create a new array using spread syntax.
    For <code>toggleTask()</code>, we map over the array and create a new object
    for the matching task. This immutable approach ensures Angular's change
    detection catches every modification.
  </p>

  <div class="tip-box">
    <strong>💡 Pro Tip</strong>
    <p>
      When working with arrays or objects in Signals, always use immutable
      update patterns (spread operator, map, filter). Mutating the array
      directly with <code>push()</code> or modifying object properties won't
      trigger Signal updates because the reference hasn't changed. Think of it
      like React's useState—you need a new reference to trigger updates.
    </p>
  </div>

  <h3>Step 4: Build the Template with New Control Flow</h3>
  <p>
    Finally, let's create the template that brings it all together. We'll use
    Angular 17's new <code>@for</code> and <code>@if</code> syntax for clean,
    performant rendering:
  </p>

  <pre><code><span class="highlight-comment">&lt;!-- Dashboard Statistics --&gt;</span>
&lt;div class="stats-panel"&gt;
  &lt;div class="stat"&gt;
    &lt;span class="label"&gt;Total Tasks&lt;/span&gt;
    &lt;span class="value"&gt;{{ totalTasks() }}&lt;/span&gt;
  &lt;/div&gt;
  &lt;div class="stat"&gt;
    &lt;span class="label"&gt;Completed&lt;/span&gt;
    &lt;span class="value"&gt;{{ completedCount() }}&lt;/span&gt;
  &lt;/div&gt;
  &lt;div class="stat"&gt;
    &lt;span class="label"&gt;Progress&lt;/span&gt;
    &lt;span class="value"&gt;{{ completionPercentage() }}%&lt;/span&gt;
  &lt;/div&gt;
&lt;/div&gt;

<span class="highlight-comment">&lt;!-- Filter Buttons --&gt;</span>
&lt;div class="filters"&gt;
  &lt;button (click)="filterStatus.set('all')"&gt;All&lt;/button&gt;
  &lt;button (click)="filterStatus.set('active')"&gt;Active&lt;/button&gt;
  &lt;button (click)="filterStatus.set('completed')"&gt;Completed&lt;/button&gt;
&lt;/div&gt;

<span class="highlight-comment">&lt;!-- Task List with @for --&gt;</span>
&lt;ul class="task-list"&gt;
  <span class="highlight-control">@for</span> (task of filteredTasks(); track task.id) {
    &lt;li [class.completed]="task.completed"&gt;
      &lt;input 
        type="checkbox" 
        [checked]="task.completed"
        (change)="toggleTask(task.id)"
      &gt;
      &lt;span class="title"&gt;{{ task.title }}&lt;/span&gt;
      &lt;span class="priority-badge" [class]="task.priority"&gt;
        {{ task.priority }}
      &lt;/span&gt;
      &lt;button (click)="deleteTask(task.id)"&gt;Delete&lt;/button&gt;
    &lt;/li&gt;
  } <span class="highlight-control">@empty</span> {
    &lt;li class="empty-state"&gt;
      No tasks found. Add one to get started!
    &lt;/li&gt;
  }
&lt;/ul&gt;</code></pre>

  <p>
    The template automatically stays in sync with our Signals. When you toggle a
    task's completion status, <code>tasks()</code> updates, which triggers
    recalculation of all computed values (<code>filteredTasks()</code>,
    <code>completedCount()</code>, <code>completionPercentage()</code>). Angular
    then updates only the specific DOM elements that display these values—the
    checkbox, the stats panel numbers, and potentially the task's position in
    the filtered list. No full component re-render necessary.
  </p>

  <p>
    This is the beauty of combining Signals with the new control flow: you get
    React-level fine-grained updates without the verbosity of manual dependency
    arrays or useEffect hooks. The reactivity is automatic and the performance
    is optimal.
  </p>
</section>
```

**Why this is good:**

- Introduces realistic scenario with context
- Example box sets up the use case
- Step-by-step breakdown with clear headers
- Multiple code blocks showing progression
- Every code section is fully explained
- Syntax highlighting applied correctly
- Explains the benefits and how it works
- Connects concepts together (Signals + computed + control flow)
- ~550 words with substantial content

---

## Example 3: Comparison Table

### ❌ BAD - Vague Comparisons

```html
<table class="comparison-table">
  <tr>
    <th>Old</th>
    <th>New</th>
  </tr>
  <tr>
    <td>Slower</td>
    <td>Faster</td>
  </tr>
  <tr>
    <td>Complex</td>
    <td>Simple</td>
  </tr>
</table>
```

**Problems:**

- No specific details
- Doesn't explain HOW or WHY
- Too brief to be useful
- Missing context

### ✅ GOOD - Detailed, Specific Comparisons

```html
<table class="comparison-table">
  <thead>
    <tr>
      <th>Aspect</th>
      <th>Old: *ngIf + Zone.js</th>
      <th>New: @if + Signals</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><strong>Change Detection</strong></td>
      <td>
        Zone.js checks entire component tree on every async event (setTimeout,
        HTTP, events). Can cause hundreds of unnecessary checks.
      </td>
      <td>
        Only updates components that consume changed Signals. Surgical precision
        with zero overhead for unchanged parts.
      </td>
    </tr>
    <tr>
      <td><strong>Import Requirements</strong></td>
      <td>
        Must import CommonModule or standalone NgIf directive. Adds to bundle
        size.
      </td>
      <td>Built into template compiler. Zero imports, zero bundle cost.</td>
    </tr>
    <tr>
      <td><strong>Type Safety</strong></td>
      <td>
        TypeScript can't narrow types after *ngIf checks. Need manual type
        assertions.
      </td>
      <td>
        Full type narrowing in @if blocks. TypeScript knows the value is
        defined.
      </td>
    </tr>
    <tr>
      <td><strong>Syntax</strong></td>
      <td>
        Requires &lt;ng-template&gt; for else blocks. Syntax: *ngIf="condition;
        else template"
      </td>
      <td>
        JavaScript-like syntax with curly braces: @if (condition) { } @else { }.
        More intuitive for developers.
      </td>
    </tr>
    <tr>
      <td><strong>Performance</strong></td>
      <td>
        Runtime directive overhead. Every *ngIf is a directive instance with
        lifecycle hooks.
      </td>
      <td>
        Compiled to optimized instructions. No runtime directive instances.
        30-40% faster rendering.
      </td>
    </tr>
  </tbody>
</table>
```

**Why this is good:**

- Specific, detailed comparisons
- Explains implications (not just "faster" but WHY and HOW MUCH)
- Multiple aspects compared (5 rows)
- Technical details (bundle size, type narrowing, compilation)
- Helps reader make informed decisions

---

## Example 4: Info Boxes

### ❌ BAD - Generic, Unhelpful

```html
<div class="info-box">
  <p>This is important information.</p>
</div>
```

### ✅ GOOD - Specific, Actionable

```html
<div class="warning-box">
  <strong>⚠️ Important: Avoid Mutating Signal Values</strong>
  <p>
    Never directly mutate objects or arrays inside Signals. This code WON'T
    trigger updates:
  </p>
  <pre><code>tasks().push(newTask);  <span class="highlight-comment">// ❌ Wrong - modifies array in place</span>
tasks()[0].completed = true;  <span class="highlight-comment">// ❌ Wrong - mutates object</span></code></pre>
  <p>Instead, always create new references:</p>
  <pre><code>tasks.update(t => [...t, newTask]);  <span class="highlight-comment">// ✅ Correct - new array</span>
tasks.update(t => t.map((task, i) => 
  i === 0 ? {...task, completed: true} : task
));  <span class="highlight-comment">// ✅ Correct - new objects</span></code></pre>
</div>
```

**Why this is good:**

- Clear, specific warning
- Shows wrong way AND right way
- Includes code examples
- Explains why it matters

---

## Key Takeaways

### For Every Section:

1. **Introduce** the topic (what and why)
2. **Show code** with complete context
3. **Explain** what the code does
4. **Highlight** key points or gotchas
5. **Connect** to real-world usage

### For Every Code Block:

1. **Paragraph before**: What we're about to see and why
2. **Code with highlighting**: Complete, runnable example
3. **Paragraph after**: How it works and what to notice
4. **Info box** (if applicable): Tips, warnings, or additional context

### Overall Article:

- **Progressive complexity**: Start simple, build up
- **Real names**: Use realistic identifiers (not foo/bar)
- **Complete examples**: No fragments or pseudo-code
- **Explanation ratio**: 70% explanation, 30% code
- **Visual aids**: Tables, boxes, grids to break up text
- **Help the reader**: Every section should teach something valuable

---

_Use these examples as your quality standard for every blog post._
