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
                    <div class="${properties.kcFormGroupClass!} ${messagesPerField.printIfExists('username',properties.kcFormGroupErrorClass!)}">
                        <div class="${properties.kcLabelWrapperClass!}">
                            <label for="username" class="${properties.kcLabelClass!}">${msg("username")}</label>
                        </div>
                        <div class="${properties.kcInputWrapperClass!}">
                            <input type="text" id="username" class="${properties.kcInputClass!}" name="username" value="${(register.formData.username!'')?html}" />
                        </div>
                    </div>
                </#if>

                <label for="firstName">${msg("firstName")}</label>
                <input type="text" id="firstName" class="${properties.kcInputClass!}" name="firstName" value="${(register.formData.firstName!'')?html}" />

                <label for="lastName">${msg("lastName")}</label>
                <input type="text" id="lastName" name="lastName" value="${(register.formData.lastName!'')?html}" />

                <label for="email">${msg("email")}</label>
                <input type="text" id="email" name="email" value="${(register.formData.email!'')?html}" />

                <label for="user.attributes.institutions">Institutions</label>
                <input id="user.attributes.institutions" name="user.attributes.institutions"/>

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
        </form>
    </#if>
    <script>
        var institutionSearchUri = "${properties.institutionSearchUri!}/institutions";

        function emailToDomain(email) {
            return email.split("@", 2)[1];
        }

        function getFormEmail() {
            return $("#email").val().trim().toLowerCase();
        }

        function isValidDomain(email, domain) {
            return emailToDomain(email) === domain;
        }

        function getStatusIcon(email, domain) {
            var statusIcon = '';
            if(isValidDomain(email, domain))
                statusIcon =  '<i style="color:#20aa3f;" class="fa fa-check-circle" aria-hidden="true"></i>';
            else
                statusIcon =  '<i style="color:#ff9e1b;" class="fa fa-warning" aria-hidden="true"></i>';

            return statusIcon;
        }

        $(document).ready(function() {

            $("#user\\.attributes\\.institutions").select2({
                placeholder: "Select Institution(s)",
                minimumInputLength: 3,
                multiple: true,
                allowClear: true,
                width: "600px",
                dropdownCssClass: "bigdrop",
                ajax: {
                    url: institutionSearchUri,
                    data: function(term, page) {
                        // Search based on user input
                        return { search: term }

                        // Search based on "email" form field
                        //var domain = emailToDomain($("#email").val());
                        //return { domain: domain }
                    },
                    results: function(data, page) {
                        return {
                            // Each result MUST have an `id` attribute
                            results: data.results
                        }
                    }
                },
                escapeMarkup: function(markup) {
                    return markup;
                },
                formatSelection: function(institution) {
                    return  institution.name + ' (' + institution.id + ') ' + getStatusIcon(getFormEmail(), institution.domain[0]);
                },
                formatResult: function(institution) {

                    return '<div class="container-fluid">' +
                           '  <div class="row">' +
                           '    <div styles="vertical-align:middle;" class="col-md-1">' +
                           '      <h1>' + getStatusIcon(getFormEmail(), institution.domain[0]) + '</h1>' +
                           '    </div>' +
                           '    <div class="col-md-11">' +
                           '      <div class="row">' +

                           '        <div class="col-md-6">' +
                           '          <div class="row">' +
                           '            <div class="col-md-12">' +
                           '              <h4>' + institution.name + '</h4>' +
                           '            </div>' +
                           '          </div>' +

                           '          <div class="row">' +
                           '            <div class="col-md-4">' +
                           '               <i class="fa fa-gavel" aria-hidden="true"></i> ' + institution.regulator +
                           '            </div>' +
                           '            <div class="col-md-8">' +
                           '               <i class="fa fa-envelope" aria-hidden="true"></i> ' + institution.domain[0] +
                           '            </div>' +
                           '          </div>' +

                           '        </div>' +

                           '        <div class="col-md-6">' +
                           '          <div class="row"><strong>Respondent ID:</strong> ' + institution.id + '</div>' +
                           '          <div class="row"><strong>EIN:</strong> 12-3456789</div>' +
                           '          <div class="row"><strong>FDIC Charter:</strong> 999999</div>' +
                           '          </div>' +
                           '        </div>' +

                           '      </div>' +
                           '    </div>' +
                           '  </div>' +
                           '</div>'
                }
            });
        });
    </script>
</@layout.registrationLayout>
