layui.use(['table', 'form'], function () {
    const table = layui.table;
    const form = layui.form;
    const $ = layui.jquery;

    form.render();

    let queryConditions = {}; // Global conditions

    // Initialize empty table (no initial request)
    table.render({
        elem: '#resultTable',
        loading: false,
        method: 'post',
        contentType: 'application/json',
        page: true,
        limit: 10,
        toolbar: true,
defaultToolbar: [
  
  {
    name: 'exports',
    title: 'Export',
    onClick: function (obj) {
      const options = obj.config;
      const tableId = options.id || 'resultTable'; // ⚡你的表格id应该是 resultTable
      const raw = layui.table.cache[tableId];

      if (!raw || typeof raw !== 'object') {
        layer.msg('No data to export');
        return;
      }

      // Open custom export panel
      obj.openPanel({
        list: [
          '<li data-type="xlsx">Export XLSX File</li>'
        ].join(''),
        done: function (panel, list) {
          list.on('click', function () {
            const type = $(this).data('type');

            if (type === 'xlsx') {
              // Get visible columns
              const ths = document.querySelectorAll(`.layui-table-view[lay-table-id="${tableId}"] .layui-table-header th[data-field]`);

              const fieldList = Array.from(ths)
                .filter(th => !th.classList.contains('layui-hide'))
                .map(th => th.getAttribute('data-field'))
                .filter(field =>
                  field &&
                  !['LAY_CHECKED', 'LAY_INDEX', 'LAY_INDEX_INIT', 'LAY_NUM'].includes(field)
                );

              const cleaned = Object.values(layui.table.clearCacheKey(raw)).map(row => {
                const filtered = {};
                fieldList.forEach(f => filtered[f] = row[f]);
                return filtered;
              });

              if (cleaned.length === 0) {
                layer.msg('No data to export');
                return;
              }

              // ✅ Define your header rename mapping (适配你的 aftercare 表格)
              const headerMap = {
                StudentName: "Student Name",
                TargetDate: "Date",
                DayOfWeek: "Day of Week"
              };

              const renamed = cleaned.map((row, rowIndex) => {
                const newRow = {};
                console.log(`👉 原始第${rowIndex+1}行:`, row);
            
                fieldList.forEach(key => {
                    let value = row[key];
                    console.log(`🔵 处理字段 ${key}，原始值:`, value);
            
                    if (key === 'TargetDate') {
                        if (typeof value === 'string') {
                            console.log(`🔴 TargetDate是字符串，准备处理:`, value);
                            if (value.includes('T')) {
                                value = value.split('T')[0];
                                console.log(`✅ TargetDate处理后（字符串split）:`, value);
                            }
                        } else if (Object.prototype.toString.call(value) === '[object Date]') {
                            console.log(`🔴 TargetDate是Date对象，准备处理:`, value);
                            value = value.toISOString().split('T')[0];
                            console.log(`✅ TargetDate处理后（Date toISOString）:`, value);
                        } else {
                            console.log(`⚠️ TargetDate是未知格式，不处理:`, value);
                        }
                    }
            
                    newRow[headerMap[key] || key] = value;
                });
            
                console.log(`👉 处理后第${rowIndex+1}行:`, newRow);
                return newRow;
            });
            
            console.log("🚀 最终准备导出的数据:", renamed);
            

              const ws = XLSX.utils.json_to_sheet(renamed);
              const wb = XLSX.utils.book_new();
              XLSX.utils.book_append_sheet(wb, ws, "Aftercare Students");
              XLSX.writeFile(wb, "aftercare_students.xlsx");
            }
          });
        }
      });
    }
  }
],

        limits: [10, 20, 50, 100],
        request: {
            pageName: 'page',
            limitName: 'limit'
        },
        data: [], // No initial data
        parseData: function (res) {
            return {
                code: 0,
                msg: '',
                count: res.totalRecords,
                data: res.students
            };
        },
        cols: [[
            {field: 'TargetDate', title: 'Date', sort: true, templet: function(d){
                return d.TargetDate.split('T')[0];
            }},
            {field: 'DayOfWeek', title: 'Day of Week', sort: true},
            {field: 'StudentName', title: 'Student Name', sort: true}
        ]],
        done: function (res, curr, count) {
            if (count === 0) {
                $(".layui-table-main").html('<div class="layui-none">No Record</div>');
            }
        }
    });

    // Fetch records
    window.fetchAftercareRecords = function (event) {
        event.preventDefault();

        const startDate = document.getElementById('startDate').value;
        const endDate = document.getElementById('endDate').value;

        if (!startDate || !endDate) {
            layer.msg('Please select both start and end dates.');
            return;
        }

        queryConditions = {
            startDate: startDate,
            endDate: endDate,
            sortField: "TargetDate", // Default sort
            sortOrder: "asc"
        };

        table.reload('resultTable', {
            url: 'https://shamrock-aftercare-system-c0cmahexfkena5cj.westus2-01.azurewebsites.net/api/aftercare_query/by-range',
            where: queryConditions,
            toolbar: true,
            defaultToolbar: [
              
              {
                name: 'exports',
                title: 'Export',
                onClick: function (obj) {
                  const options = obj.config;
                  const tableId = options.id || 'resultTable'; // ⚡你的表格id应该是 resultTable
                  const raw = layui.table.cache[tableId];
            
                  if (!raw || typeof raw !== 'object') {
                    layer.msg('No data to export');
                    return;
                  }
            
                  // Open custom export panel
                  obj.openPanel({
                    list: [
                      '<li data-type="xlsx">Export XLSX File</li>'
                    ].join(''),
                    done: function (panel, list) {
                      list.on('click', function () {
                        const type = $(this).data('type');
            
                        if (type === 'xlsx') {
                          // Get visible columns
                          const ths = document.querySelectorAll(`.layui-table-view[lay-table-id="${tableId}"] .layui-table-header th[data-field]`);
            
                          const fieldList = Array.from(ths)
                            .filter(th => !th.classList.contains('layui-hide'))
                            .map(th => th.getAttribute('data-field'))
                            .filter(field =>
                              field &&
                              !['LAY_CHECKED', 'LAY_INDEX', 'LAY_INDEX_INIT', 'LAY_NUM'].includes(field)
                            );
            
                          const cleaned = Object.values(layui.table.clearCacheKey(raw)).map(row => {
                            const filtered = {};
                            fieldList.forEach(f => filtered[f] = row[f]);
                            return filtered;
                          });
            
                          if (cleaned.length === 0) {
                            layer.msg('No data to export');
                            return;
                          }
            
                          // ✅ Define your header rename mapping (适配你的 aftercare 表格)
                          const headerMap = {
                            StudentName: "Student Name",
                            TargetDate: "Date",
                            DayOfWeek: "Day of Week"
                          };
            
                          const renamed = cleaned.map((row, rowIndex) => {
                            const newRow = {};
                            console.log(`👉 原始第${rowIndex+1}行:`, row);
                        
                            fieldList.forEach(key => {
                                let value = row[key];
                                console.log(`🔵 处理字段 ${key}，原始值:`, value);
                        
                                if (key === 'TargetDate') {
                                    if (typeof value === 'string') {
                                        console.log(`🔴 TargetDate是字符串，准备处理:`, value);
                                        if (value.includes('T')) {
                                            value = value.split('T')[0];
                                            console.log(`✅ TargetDate处理后（字符串split）:`, value);
                                        }
                                    } else if (Object.prototype.toString.call(value) === '[object Date]') {
                                        console.log(`🔴 TargetDate是Date对象，准备处理:`, value);
                                        value = value.toISOString().split('T')[0];
                                        console.log(`✅ TargetDate处理后（Date toISOString）:`, value);
                                    } else {
                                        console.log(`⚠️ TargetDate是未知格式，不处理:`, value);
                                    }
                                }
                        
                                newRow[headerMap[key] || key] = value;
                            });
                        
                            console.log(`👉 处理后第${rowIndex+1}行:`, newRow);
                            return newRow;
                        });
                        
                        console.log("🚀 最终准备导出的数据:", renamed);
                        
            
                          const ws = XLSX.utils.json_to_sheet(renamed);
                          const wb = XLSX.utils.book_new();
                          XLSX.utils.book_append_sheet(wb, ws, "Aftercare Students");
                          XLSX.writeFile(wb, "aftercare_students.xlsx");
                        }
                      });
                    }
                  });
                }
              }
            ],

            page: { curr: 1 }
        });
    };

    // Listen table sort event
    table.on('sort(resultTable)', function(obj){
        queryConditions.sortField = obj.field;
        queryConditions.sortOrder = obj.type || 'asc'; // asc or desc

        table.reload('resultTable', {
            url: 'https://shamrock-aftercare-system-c0cmahexfkena5cj.westus2-01.azurewebsites.net/api/aftercare_query/by-range',
            where: queryConditions,
            toolbar: true,
            defaultToolbar: [
              
              {
                name: 'exports',
                title: 'Export',
                onClick: function (obj) {
                  const options = obj.config;
                  const tableId = options.id || 'resultTable'; // ⚡你的表格id应该是 resultTable
                  const raw = layui.table.cache[tableId];
            
                  if (!raw || typeof raw !== 'object') {
                    layer.msg('No data to export');
                    return;
                  }
            
                  // Open custom export panel
                  obj.openPanel({
                    list: [
                      '<li data-type="xlsx">Export XLSX File</li>'
                    ].join(''),
                    done: function (panel, list) {
                      list.on('click', function () {
                        const type = $(this).data('type');
            
                        if (type === 'xlsx') {
                          // Get visible columns
                          const ths = document.querySelectorAll(`.layui-table-view[lay-table-id="${tableId}"] .layui-table-header th[data-field]`);
            
                          const fieldList = Array.from(ths)
                            .filter(th => !th.classList.contains('layui-hide'))
                            .map(th => th.getAttribute('data-field'))
                            .filter(field =>
                              field &&
                              !['LAY_CHECKED', 'LAY_INDEX', 'LAY_INDEX_INIT', 'LAY_NUM'].includes(field)
                            );
            
                          const cleaned = Object.values(layui.table.clearCacheKey(raw)).map(row => {
                            const filtered = {};
                            fieldList.forEach(f => filtered[f] = row[f]);
                            return filtered;
                          });
            
                          if (cleaned.length === 0) {
                            layer.msg('No data to export');
                            return;
                          }
            
                          // ✅ Define your header rename mapping (适配你的 aftercare 表格)
                          const headerMap = {
                            StudentName: "Student Name",
                            TargetDate: "Date",
                            DayOfWeek: "Day of Week"
                          };
            
                          const renamed = cleaned.map((row, rowIndex) => {
                            const newRow = {};
                            console.log(`👉 原始第${rowIndex+1}行:`, row);
                        
                            fieldList.forEach(key => {
                                let value = row[key];
                                console.log(`🔵 处理字段 ${key}，原始值:`, value);
                        
                                if (key === 'TargetDate') {
                                    if (typeof value === 'string') {
                                        console.log(`🔴 TargetDate是字符串，准备处理:`, value);
                                        if (value.includes('T')) {
                                            value = value.split('T')[0];
                                            console.log(`✅ TargetDate处理后（字符串split）:`, value);
                                        }
                                    } else if (Object.prototype.toString.call(value) === '[object Date]') {
                                        console.log(`🔴 TargetDate是Date对象，准备处理:`, value);
                                        value = value.toISOString().split('T')[0];
                                        console.log(`✅ TargetDate处理后（Date toISOString）:`, value);
                                    } else {
                                        console.log(`⚠️ TargetDate是未知格式，不处理:`, value);
                                    }
                                }
                        
                                newRow[headerMap[key] || key] = value;
                            });
                        
                            console.log(`👉 处理后第${rowIndex+1}行:`, newRow);
                            return newRow;
                        });
                        
                        console.log("🚀 最终准备导出的数据:", renamed);
                        
            
                          const ws = XLSX.utils.json_to_sheet(renamed);
                          const wb = XLSX.utils.book_new();
                          XLSX.utils.book_append_sheet(wb, ws, "Aftercare Students");
                          XLSX.writeFile(wb, "aftercare_students.xlsx");
                        }
                      });
                    }
                  });
                }
              }
            ],

            page: { curr: 1 },
            initSort: obj // Highlight current sort column
        });
    });
});
