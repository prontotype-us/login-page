React = require 'react'
{Router, Route, IndexRoute, Link, hashHistory, browserHistory} = require 'react-router'
fetch$ = require 'kefir-fetch'
{ValidatedFormMixin} = require 'pronto-validated-form'

history = browserHistory

window.options = {}

# Field definitions

email_field =
    name: 'email'
    type: 'email'
    icon: 'envelope'
    error_message: 'Please enter a valid email'

password_field =
    name: 'password'
    type: 'password'
    icon: 'key'
    error_message: 'Please enter a password'

confirm_password_field =
    name: 'confirm_password'
    type: 'password'
    icon: 'key'
    error_message: 'Confirm your password'

token_field =
    name: 'reset_token'
    type: 'hidden'
    error_message: 'No reset token'

Dispatcher =
    doSubmit: (url, data) ->
        fetch$ 'post', url, {body: data}

LoginMixin =
    showNext: (response) ->
        next = response?.redirect || @props.location.query.next || '/'
        if window.location.hash?.length
            next += window.location.hash
        window.location = next

    showSuccess: ->
        history.push {pathname: @props.location.pathname + '/success', query: @props.location.query}

    handleError: (response) ->
        @setState {errors: response.errors, loading: false}

    onSubmit: (values) ->
        @submitted$ = Dispatcher.doSubmit @props.url, values
        @submitted$.onValue @handleResponse
        @submitted$.onError @handleError

LoginForm = React.createClass
    mixins: [ValidatedFormMixin, LoginMixin]

    getDefaultProps: ->
        title: "Log in"
        url: '/login.json'
        fields:
            email: email_field
            password: password_field
        button:
            text: 'Log in'
            submitting_text: 'Logging in...'

    getInitialState: ->
        initial_values = {}
        Object.keys(@props.fields).map (f_k) =>
            initial_values[f_k] = @props.fields[f_k]?.value || ''
        return {
            values: initial_values
            errors: {}
            loading: false
        }

    handleResponse: (response) ->
        if response.errors?
            @handleError response
        else if @props.onSuccess?
            @props.onSuccess response
        else
            @showNext response

    render: ->
        <div>
            {if @props.title?
                <h3>{@props.title}</h3>
            }
            <form onSubmit=@trySubmit>
                {@renderFields()}
                <button type='submit' disabled={@state.loading}>
                    {if @state.loading then @props.button.submitting_text else @props.button.text}
                </button>
            </form>
        </div>

SignupForm = React.createClass
    mixins: [ValidatedFormMixin, LoginMixin]

    getDefaultProps: ->
        title: "Sign up"
        url: '/signup.json'
        fields:
            email: email_field
            password: password_field
        button:
            text: 'Sign up'
            submitting_text: 'Signing up...'

    getInitialState: ->
        initial_values = {}
        Object.keys(@props.fields).map (f_k) =>
            initial_values[f_k] = @props.fields[f_k]?.value || ''
        return {
            values: initial_values
            errors: {}
            loading: false
        }

    handleResponse: (response) ->
        if response.errors?
            @handleError response
        else if @props.onSuccess?
            @props.onSuccess response
        else
            @showNext response

    render: ->
        <div>
            {if @props.title?
                <h3>{@props.title}</h3>
            }
            <form onSubmit=@trySubmit>
                {@renderFields()}
                <button type='submit' disabled={@state.loading}>
                    {if @state.loading then @props.button.submitting_text else @props.button.text}
                </button>
            </form>
        </div>

SetupForm = React.createClass
    mixins: [ValidatedFormMixin, LoginMixin]

    getDefaultProps: ->
        title: "Sign up"
        url: '/setup.json'
        fields:
            email: email_field
            password: password_field
        button:
            text: 'Sign up'
            submitting_text: 'Signing up...'

    getInitialState: ->
        initial_values = {}
        Object.keys(@props.fields).map (f_k) =>
            initial_values[f_k] = @props.fields[f_k]?.value || ''
        return {
            values: initial_values
            errors: {}
            loading: false
        }

    handleResponse: (response) ->
        if response.errors?
            @handleError response
        else if @props.onSuccess?
            @props.onSuccess response
        else
            @showNext response

    render: ->
        <div>
            {if @props.title?
                <h3>{@props.title}</h3>
            }
            <form onSubmit=@trySubmit>
                {@renderFields()}
                <button type='submit' disabled={@state.loading}>
                    {if @state.loading then @props.button.submitting_text else @props.button.text}
                </button>
            </form>
        </div>

ForgotForm = React.createClass
    mixins: [ValidatedFormMixin, LoginMixin]

    getDefaultProps: ->
        title: "Forgot your password?"
        url: '/forgot.json'
        fields:
            email: email_field
        button:
            text: 'Reset password'
            submitting_text: 'Processing...'

    getInitialState: ->
        values:
            email: ''
        errors: {}
        loading: false

    handleResponse: (response) ->
        if response.errors?
            @handleError response
        else if @props.onSuccess?
            @props.onSuccess response
        else
            @showSuccess()

    render: ->
        <div>
            {if @props.title?
                <h3>{@props.title}</h3>
            }
            <form onSubmit=@trySubmit>
                {@renderFields()}
                <button type='submit' disabled={@state.loading}>
                    {if @state.loading then @props.button.submitting_text else @props.button.text}
                </button>
            </form>
        </div>

ForgotSuccess = React.createClass
    render: ->
        <div className='center'>
            {if options.forgot_success_view
                options.forgot_success_view
            else
                <div>
                    <h3>Check your email!</h3>
                    <p>We sent you an email with instructions to reset your password.</p>
                </div>
            }
        </div>

ResetForm = React.createClass
    mixins: [ValidatedFormMixin, LoginMixin]

    getDefaultProps: ->
        url: '/reset.json'
        fields:
            password: password_field
            confirm_password: confirm_password_field
            reset_token: token_field
        button:
            text: 'Set password'
            submitting_text: 'Processing...'

    getInitialState: ->
        values:
            password: ''
            confirm_password: ''
            reset_token: @props.params.reset_token || ''
        errors: {}
        loading: false

    handleResponse: (response) ->
        if response.errors?
            @handleError response
        else if @props.onSuccess?
            @props.onSuccess response
        else
            @showSuccess()

    render: ->

        <div>
            {if @props.title?
                <h3>{@props.title}</h3>
            }
            <form onSubmit=@trySubmit>
                {@renderField('password')}
                {@renderField('confirm_password')}
                {@renderField('reset_token')}
                <button type='submit' disabled={@state.loading}>
                    {if @state.loading then @props.button.submitting_text else @props.button.text}
                </button>
            </form>
        </div>

ResetSuccess = ({location}) ->
    <div className='center'>
        {if options.success_view
            options.success_view
        else
            <div>
                <h3>Successfully set your password</h3>
                <div className='login-links'>
                    <Link to={pathname: "/login", query: location.query}>Continue to login</Link>
                </div>
            </div>
        }
    </div>

App = React.createClass
    getInitialState: ->
        active: 'login'

    render: ->
        path = @props.routes.slice(-1)[0].name
        if !path.length or path=='unknown' then path = 'login'

        login_tab = if !options.hide_login
            login_tab_class = if path == 'login' or (!options.signup_first and path=='/') then 'active' else ''
            <Link to={pathname: "/login", query: @props.location.query} activeClassName='active' className=login_tab_class>Log in</Link>
        signup_tab = if !options.hide_signup
            signup_tab_class = if path == 'signup' or (options.signup_first and path=='/') then 'active' else ''
            <Link to={pathname: "/signup", query: @props.location.query} activeClassName='active' className=signup_tab_class>Sign up</Link>

        tabs = if !options.signup_first
            <div className='login-tabs'>
                {login_tab}
                {signup_tab}
            </div>
        else
            <div className='login-tabs'>
                {signup_tab}
                {login_tab}
            </div>

        links =
            login:
                <div className='login-links'>
                    {if !options.hide_forgot then <Link to={pathname: "/forgot", query: @props.location.query}>Forgot Password?</Link>}
                    {if !options.hide_signup then <Link to={pathname: "/signup", query: @props.location.query}>Don't have an account?</Link>}
                </div>
            signup:
                <div className='login-links'>
                    {if !options.hide_login then <Link to={pathname: "/login", query: @props.location.query}>Already have an account?</Link>}
                </div>
            forgot:
                <div className='login-links'>
                    {if !options.hide_login then <Link to={pathname: "/login", query: @props.location.query}>&laquo; Nevermind</Link>}
                    {if !options.hide_signup then <Link to={pathname: "/signup", query: @props.location.query}>Don't have an account?</Link>}
                </div>
            reset: null

        <div id='login-page' className="#{path}" >
            {options.header}
            {if !options.hide_tabs then tabs}
            <div id='login-inner'>
                {options[path]?.intro}
                {options[path]?.befores}
                {React.cloneElement @props.children, options[path]}
                {links[path]}
                {options[path]?.extras}
            </div>
            {options.footer}
        </div>

window.options = {}

setNext = (nextState, replace) ->
    next = nextState.location.pathname
    replace '/?next=' + next

LoginPage = ({options}) ->
    Object.assign window.options, options
    index_route = if not options.signup_first
        <IndexRoute name="login" component=LoginForm />
    else
        <IndexRoute name="signup" component=SignupForm />
    routes =
        <Route path="/" component=App>
            {index_route}
            <Route path="login" name="login" component=LoginForm />
            <Route path="reset/:reset_token" name="reset" component=ResetForm />
            <Route path="reset/:reset_token/success" name="reset-success" component=ResetSuccess />
            <Route path="welcome/:reset_token" name="reset" component=ResetForm />
            <Route path="welcome/:reset_token/success" name="reset-success" component=ResetSuccess />
            {if !options.hide_signup then <Route path="signup" name="signup" component=SignupForm />}
            {if !options.hide_forgot then <Route path="forgot" name="forgot" component=ForgotForm />}
            {if !options.hide_forgot then <Route path="forgot/success" name="forgot-success" component=ForgotSuccess />}
            {if !options.hide_setup then <Route path="setup" name="setup" component=SetupForm />}
            {options.extra_routes}
            <Route path="*" name="unknown" component=LoginForm onEnter=setNext />
        </Route>
    <Router routes=routes history=history />

module.exports = {
    LoginPage
    LoginForm
    SignupForm
    ForgotForm
    ResetForm
}
