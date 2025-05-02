layui.use(['form'], function() {
    const form = layui.form;
    form.render();
});

function submitFixedRule() {
    const form = document.getElementById('fixedRuleForm');

    const selectedDays = [];
    document.querySelectorAll('input[name="dayOfWeek"]:checked').forEach(function (checkbox) {
        selectedDays.push(parseInt(checkbox.value));
    });

    if (selectedDays.length === 0) {
        layer.msg('Please select at least one day.');
        return;
    }

    const studentName = form.studentName.value.trim();
    const effectiveFrom = form.effectiveFrom.value;
    const effectiveTo = form.effectiveTo.value || null;
    const pickupTimeType = parseInt(form.pickup_time_type.value);  //  新增字段获取

    let successCount = 0;
    let failCount = 0;

    selectedDays.forEach(function(day) {
        const data = {
            studentName: studentName,
            dayOfWeek: day,
            effectiveFrom: effectiveFrom,
            effectiveTo: effectiveTo,
            pickupTimeType: pickupTimeType
        };

        axios.post('https://shamrock-aftercare-system-c0cmahexfkena5cj.westus2-01.azurewebsites.net/api/aftercare_rules', data)
            .then(res => {
                successCount++;
                checkComplete();
            })
            .catch(err => {
                console.error(err);
                failCount++;
                checkComplete();
            });
    });

    function checkComplete() {
        if (successCount + failCount === selectedDays.length) {
            if (failCount === 0) {
                layer.msg('Fixed rules registered successfully!');
                form.reset();
                layui.form.render();
            } else {
                layer.msg(`Partial success: ${successCount} succeeded, ${failCount} failed`);
            }
        }
    }
}


function submitOneTime() {
    const form = document.getElementById('oneTimeForm');
    const data = {
        studentName: form.studentName.value.trim(),
        aftercareDate: form.aftercareDate.value,
        pickupTimeType: parseInt(form.pickup_time_type.value)  //  新增字段
    };

    axios.post('https://shamrock-aftercare-system-c0cmahexfkena5cj.westus2-01.azurewebsites.net/api/aftercare_onetime', data)
        .then(res => {
            layer.msg('One-time aftercare registered successfully');
            form.reset();
            layui.form.render();
        })
        .catch(err => {
            console.error(err);
            layer.msg('Failed to register one-time aftercare');
        });
}

