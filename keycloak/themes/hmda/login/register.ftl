<#import "template.ftl" as layout>
<@layout.registrationLayout; section>
  <#if section = "title">
    ${msg("registerWithTitle",(realm.displayName!''))}
  <#elseif section = "header">
    ${msg("registerWithTitleHtml",(realm.displayNameHtml!''))}
  <#elseif section = "form">
    <form id="kc-register-form" class="usa-form" action="${url.registrationAction}" method="post">
      <fieldset>
        <input type="text" readonly value="this is not a login form" style="display: none;">
        <input type="password" readonly value="this is not a login form" style="display: none;">
        <legend class="usa-drop_text">Create an account</legend>
        <span>or <a href="${url.loginUrl}">go back to login</a></span>

        <#if !realm.registrationEmailAsUsername>
          <label for="username" class="${properties.kcLabelClass!}">${msg("username")}</label>
          <input type="text" id="username" class="${properties.kcInputClass!}" name="username" value="${(register.formData.username!'')?html}" />
        </#if>

        <label for="firstName">${msg("firstName")}</label>
        <input type="text" id="firstName" class="${properties.kcInputClass!}" name="firstName" value="${(register.formData.firstName!'')?html}" />

        <label for="lastName">${msg("lastName")}</label>
        <input type="text" id="lastName" name="lastName" value="${(register.formData.lastName!'')?html}" />

        <label for="email">${msg("email")}</label>
        <input type="text" id="email" name="email" value="${(register.formData.email!'')?html}" />

        <label>Select your institutions</label>
        <div id="institutions">
          <span class="usa-input-help-message">After entering your email address above, a list of available institutions, based on your email domain, will appear.</span>
        </div>

        <input id="user.attributes.institutions" name="user.attributes.institutions" class="usa-skipnav" hidden style="display:none;"/>

        <#if passwordRequired>
          <label for="password">${msg("password")}</label>
          <input type="password" id="password" name="password" />

          <label for="password-confirm">${msg("passwordConfirm")}</label>
          <input type="password" id="password-confirm" name="password-confirm" />
        </#if>

        <#if recaptchaRequired??>
          <div class="g-recaptcha" data-size="compact" data-sitekey="${recaptchaSiteKey}"></div>
        </#if>

        <input name="register" id="kc-register" type="submit" value="${msg("doRegister")}"/>
      </fieldset>

      <p class="usa-text-small">Having trouble? Please contact <a href="mailto:${properties.supportEmailTo!}?subject=${properties.supportEmailSubject!}">${properties.supportEmailTo!}</a></p>
    </form>
  </#if>
</@layout.registrationLayout>

<script>
var institutionSearchUri = "${properties.institutionSearchUri!}/institutions";
var emailExp = new RegExp("[a-zA-Z0-9!#$%&'*+/=?^_`{|}~.-]+@[a-zA-Z0-9-]+(\\.[a-zA-Z0-9-]+)*");

function emailToDomain(email) {
  return email.split("@", 2)[1];
}

function getRSSD(externalIds) {
  var RSSD = '';
  for (var i = 0; i < externalIds.length; i++) {
    if(externalIds[i].name === 'RSSD ID') {
      RSSD = externalIds[i].value;
      break;
    }
  }

  return RSSD;
}

function createHTML(institutions) {
  var html = '<ul class="usa-unstyled-list">';
  var checked = (institutions.length === 1) ? 'checked' : ''

  for (var i = 0; i < institutions.length; i++) {
    var RSSD = getRSSD(institutions[i].externalIds)
    html = html + '<li>'
      + '<input class="institutionsCheck" type="checkbox" id="'
      + institutions[i].id + '" name="institutions" value="'
      + institutions[i].id + '"' + checked + '>'
      + '<label for="' + institutions[i].id + '"><strong>' + institutions[i].name + '</strong> (RSSD: ' + RSSD + ')</label></li>'
  }
  html = html + '</ul></fieldset>';

  return html;
}

function buildList(institutions) {
  if(institutions.length === 0) {
    $('#institutions').html('<span class="usa-input-error-message">Sorry, we couldn\'t find that email domain. Please contact <a href="mailto:${properties.supportEmailTo!}?subject=${properties.supportEmailSubject!}">${properties.supportEmailTo!}</a> for help getting registered.</span>');
  } else {
    var html = createHTML(institutions);
    $('#institutions').html(html);
  }

  addInstitutionsToInput();
}

function getInstitutions(domain) {
  $.ajax({
    url: institutionSearchUri,
    data: { domain: domain }
  })
  .success(function(institutions) {
    buildList(institutions.results);
  })
  .fail(function(request, status, error) {
    ('#institutions').html('<span class="usa-input-error-message">Sorry, something went wrong. Please contact <a href="mailto:${properties.supportEmailTo!}?subject=${properties.supportEmailSubject!}">${properties.supportEmailTo!}</a> for help getting registered <strong>or</strong> try again in a few minutes.</span>');
  });
}

function addInstitutionsToInput() {
  var listOfInstitutions = [];
  // add to the user.attributes.institutions input
  $('.institutionsCheck').each(function(index){
    if($(this).prop('checked')) {
      listOfInstitutions.push($(this).val())
    }
  })
  $("#user\\.attributes\\.institutions").val(listOfInstitutions.join(","));
}

$(document).ready(function() {
  $('#email').on('blur, keyup', function() {
    if($('#email').val() === '' || $('#email').val() === null) {
      $('#institutions').html('<span class="usa-input-error-message">After entering your email address above, a list of available institutions, based on your email domain, will appear.</span>');
    } else {
      if(emailExp.test($('#email').val())) {
        getInstitutions(emailToDomain($('#email').val()));
      }
    }
  });

  if($('#email').val() !== '' && $('#email').val() !== null) {
    getInstitutions(emailToDomain($('#email').val()));
  }

  $('#institutions').on('click', '.institutionsCheck', addInstitutionsToInput);
});
</script>
