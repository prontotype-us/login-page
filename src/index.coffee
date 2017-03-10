React = require 'react'
{Router, Route, IndexRoute, Link, hashHistory, browserHistory} = require 'react-router'
fetch$ = require 'kefir-fetch'
{ValidatedFormMixin} = require 'validated-form'

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
    showNext: (resp) ->
        next = resp?.redirect || @props.location.query.next || '/'
        window.location = next

    showSuccess: ->
        history.push {pathname: @props.location.pathname + '/success', query: @props.location.query}

    handleError: (resp) ->
        @setState {errors: resp.errors}

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

    getInitialState: ->
        values:
            email: ''
            password: ''
        errors: {}
        loading: false

    handleResponse: (resp) ->
        if resp.errors?
            @handleError resp
        else
            @showNext resp

    render: ->
        <div>
            <h3>{@props.title}</h3>
            <form onSubmit=@trySubmit>
                {@renderFields()}
                <button type='submit' disabled={@state.loading}>
                    {if @state.loading then 'Logging in...' else 'Log in'}
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

    getInitialState: ->
        initial_values = {}
        Object.keys(@props.fields).map (f_k) =>
            initial_values[f_k] = @props.fields[f_k]?.value || ''
        return {
            values: initial_values
            errors: {}
            loading: false
        }

    handleResponse: (resp) ->
        if resp.errors?
            @handleError resp
        else
            @showNext resp

    render: ->
        <div>
            <h3>{@props.title}</h3>
            <form onSubmit=@trySubmit>
                {@renderFields()}
                <button type='submit' disabled={@state.loading}>
                    {if @state.loading then 'Signing up...' else 'Sign up'}
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

    getInitialState: ->
        values:
            email: ''
        errors: {}
        loading: false

    handleResponse: (resp) ->
        if resp.errors?
            @handleError resp
        else
            @showSuccess()

    render: ->
        <div>
            <h3>{@props.title}</h3>
            <form onSubmit=@trySubmit>
                {@renderFields()}
                <button type='submit' disabled={@state.loading}>
                    {if @state.loading then 'Processing...' else 'Reset password'}
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

    getInitialState: ->
        values:
            password: ''
            confirm_password: ''
            reset_token: @props.params.reset_token || ''
        errors: {}
        loading: false

    handleResponse: (resp) ->
        if resp.errors?
            @handleError resp
        else
            @showSuccess()

    render: ->
        console.log 'hello jones', @props
        <div>
            <h3>{@props.title}</h3>
            <form onSubmit=@trySubmit>
                {@renderField('password')}
                {@renderField('confirm_password')}
                {@renderField('reset_token')}
                <button type='submit' disabled={@state.loading}>
                    {if @state.loading then 'Processing...' else 'Set password'}
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
                <div className='form-links'>
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

        tabs =
            <div className='login-tabs'>
                {if !options.hide_login then <Link to={pathname: "/login", query: @props.location.query} activeClassName='active'>Log in</Link>}
                {if !options.hide_signup then <Link to={pathname: "/signup", query: @props.location.query} activeClassName='active'>Sign up</Link>}
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

        <div id='login-page'>
            {options.header}
            {if !options.hide_tabs then tabs}
            <div id='login-inner'>
                {options[path]?.intro}
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
    routes =
        <Route path="/" component=App>
            <IndexRoute name="login" component=LoginForm />
            <Route path="login" name="login" component=LoginForm />
            <Route path="reset/:reset_token" name="reset" component=ResetForm />
            <Route path="reset/:reset_token/success" name="reset-success" component=ResetSuccess />
            <Route path="welcome/:reset_token" name="reset" component=ResetForm />
            <Route path="welcome/:reset_token/success" name="reset-success" component=ResetSuccess />
            {if !options.hide_signup then <Route path="signup" name="signup" component=SignupForm />}
            {if !options.hide_forgot then <Route path="forgot" name="forgot" component=ForgotForm />}
            {if !options.hide_forgot then <Route path="forgot/success" name="forgot-success" component=ForgotSuccess />}
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
